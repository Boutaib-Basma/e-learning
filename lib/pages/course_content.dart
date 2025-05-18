import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert';

class CourseContentPage extends StatefulWidget {
  final String lessonTitle;
  final String courseTitle;
  final String videoUrl;
  final String lessonDescription;
  final String lessonDuration;
  final int? studentId;
  final int lessonId;
  final int courseId;
  final Function onLessonCompleted;
  final Function? onNextLesson;

  const CourseContentPage({
    Key? key,
    required this.lessonTitle,
    required this.courseTitle,
    required this.videoUrl,
    required this.lessonDescription,
    required this.lessonDuration,
    required this.lessonId,
    required this.courseId,
    this.studentId,
    required this.onLessonCompleted,
    this.onNextLesson,
  }) : super(key: key);

  @override
  _CourseContentPageState createState() => _CourseContentPageState();
}

class _CourseContentPageState extends State<CourseContentPage> {
  YoutubePlayerController? _controller;
  bool _isCompleted = false;
  bool _isLoading = true;
  String? _errorMessage;
  Duration? _videoDuration;
  int _lastSavedSecond = 0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _parseDuration();
    initializePlayer();
  }

  void _parseDuration() {
    try {
      final parts = widget.lessonDuration.split(':');
      if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        _videoDuration = Duration(hours: hours, minutes: minutes, seconds: seconds);
      } else {
        throw FormatException('Invalid duration format');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de format de durée: $e';
      });
      _videoDuration = const Duration(seconds: 0);
    }
  }

  void initializePlayer() {
    try {
      log('Initializing YouTube player with URL: ${widget.videoUrl}');
      String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      log('Extracted video ID: $videoId');
      if (videoId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'URL YouTube invalide';
        });
        return;
      }

      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
        ),
      )..addListener(() {
          if (_controller!.value.isReady) {
            final currentPosition = _controller!.value.position;
            final playerState = _controller!.value.playerState;

            // Sauvegarder sur pause
            if (playerState == PlayerState.paused && !_isCompleted) {
              final currentSecond = currentPosition.inSeconds;
              _updateLessonProgress(currentSecond);
              _lastSavedSecond = currentSecond;
              log('Progress saved on pause: $currentSecond seconds');
            }

            // Vérifier la complétion
            if (!_isCompleted && _videoDuration != null && currentPosition >= _videoDuration!) {
              setState(() {
                _isCompleted = true;
              });
              widget.onLessonCompleted();
              _updateLessonProgress(currentPosition.inSeconds);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Leçon complétée! Passage à la leçon suivante.'),
                ),
              );
              _controller!.pause();
              if (widget.onNextLesson != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.onNextLesson!();
                });
              }
            }
          }
          setState(() {});
        });

      // Sauvegarder la progression toutes les 5 secondes
      _progressTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        if (_controller != null && _controller!.value.isPlaying && !_isCompleted) {
          final currentSecond = _controller!.value.position.inSeconds;
          _updateLessonProgress(currentSecond);
          _lastSavedSecond = currentSecond;
          log('Progress saved periodically: $currentSecond seconds');
        }
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      log('Error initializing player: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur d\'initialisation du lecteur: $e';
      });
    }
  }

  Future<void> _updateLessonProgress(int lastSecond) async {
    if (widget.studentId == null) {
      log('No studentId provided, skipping progress update API call');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) {
        log('No auth token found');
        return;
      }

      final HttpClient client = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      final ioClient = IOClient(client);

      final payload = {
        'id': 0,
        'studentId': widget.studentId,
        'lessonId': widget.lessonId,
        'courseId': widget.courseId,
        'lastSecond': lastSecond,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };

      final response = await ioClient.post(
        Uri.parse('https://192.168.1.128:5001/api/LessonProgress'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      log('Lesson Progress Update API Response Status: ${response.statusCode}');
      log('Lesson Progress Update API Response Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        log('Failed to update lesson progress: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la mise à jour du progrès: ${response.statusCode}'),
          ),
        );
      } else {
        _lastSavedSecond = lastSecond;
      }
    } catch (e) {
      log('Error updating lesson progress: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du progrès: $e'),
        ),
      );
    }
  }

  void _updateLessonProgressSync(int lastSecond) {
    _updateLessonProgress(lastSecond);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_controller != null && !_isCompleted) {
          final currentSecond = _controller!.value.position.inSeconds;
          await _updateLessonProgress(currentSecond);
          log('Progress saved on back press: $currentSecond seconds');
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.lessonTitle),
              Text(
                widget.courseTitle,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildVideoPlayer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.lessonTitle} - ${widget.courseTitle}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.lessonDescription,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    if (_isCompleted && widget.onNextLesson == null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Cours terminé!',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return Container(
        height: 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: 200,
        child: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    return YoutubePlayer(
      controller: _controller!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
      progressColors: const ProgressBarColors(
        playedColor: Colors.red,
        handleColor: Colors.redAccent,
      ),
      onReady: () {
        log('YouTube player ready');
      },
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    if (_controller != null && _controller!.value.isReady && !_isCompleted) {
      final currentSecond = _controller!.value.position.inSeconds;
      if (currentSecond > 0) {
        _updateLessonProgressSync(currentSecond);
        log('Progress saved on dispose: $currentSecond seconds');
      }
    }
    _controller?.dispose();
    super.dispose();
  }
}