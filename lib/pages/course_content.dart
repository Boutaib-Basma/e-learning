import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CourseContentPage extends StatefulWidget {
  final String lessonTitle;
  final String courseTitle;
  final Function onLessonCompleted;
  final Function? onNextLesson;

  const CourseContentPage({
    Key? key,
    required this.lessonTitle,
    required this.courseTitle,
    required this.onLessonCompleted,
    this.onNextLesson,
  }) : super(key: key);

  @override
  _CourseContentPageState createState() => _CourseContentPageState();
}

class _CourseContentPageState extends State<CourseContentPage> {
  late VideoPlayerController _controller;
  bool _isCompleted = false;
  bool _showControls = false;
  bool _isFullScreen = false;
  late Duration _currentPosition;
  late Duration _totalDuration;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
      ..initialize().then((_) {
        setState(() {
          _totalDuration = _controller.value.duration;
          _currentPosition = _controller.value.position;
        });
        _controller.addListener(_updateProgress);
      });
  }

  void _updateProgress() {
    setState(() {
      _currentPosition = _controller.value.position;
      _totalDuration = _controller.value.duration;
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _seekForward() {
    final newPosition = _controller.value.position + Duration(seconds: 10);
    _controller.seekTo(newPosition > _totalDuration ? _totalDuration : newPosition);
  }

  void _seekBackward() {
    final newPosition = _controller.value.position - Duration(seconds: 10);
    _controller.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _toggleFullScreen() {
    if (_isFullScreen) {
      Navigator.of(context).pop();
      setState(() {
        _isFullScreen = false;
      });
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: _buildVideoPlayer(fullScreen: true),
            ),
          ),
          fullscreenDialog: true,
        ),
      );
      setState(() {
        _isFullScreen = true;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  Widget _buildVideoPlayer({bool fullScreen = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: fullScreen 
                      ? MediaQuery.of(context).size.width / MediaQuery.of(context).size.height
                      : _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
          if (_showControls || !_controller.value.isPlaying)
            Container(
              // color: Colors.black54,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.replay_10, size: 30, color: Colors.white),
                        onPressed: _seekBackward,
                      ),
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 50,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                      IconButton(
                        icon: Icon(Icons.forward_10, size: 30, color: Colors.white),
                        onPressed: _seekForward,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          _formatDuration(_currentPosition),
                          style: TextStyle(color: Colors.white),
                        ),
                        Expanded(
                          child: Slider(
                            value: _currentPosition.inSeconds.toDouble(),
                            min: 0,
                            max: _totalDuration.inSeconds.toDouble(),
                            onChanged: (value) {
                              setState(() {
                                _currentPosition = Duration(seconds: value.toInt());
                                _controller.seekTo(_currentPosition);
                              });
                            },
                            activeColor: Colors.red,
                            inactiveColor: Colors.grey,
                          ),
                        ),
                        Text(
                          _formatDuration(_totalDuration),
                          style: TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: Icon(
                            fullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                            color: Colors.white,
                          ),
                          onPressed: _toggleFullScreen,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen ? null : AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.lessonTitle),
            Text(
              widget.courseTitle,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: _isFullScreen 
          ? _buildVideoPlayer(fullScreen: true)
          : SingleChildScrollView(
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Dans cette leçon, vous allez apprendre les concepts fondamentaux. Suivez attentivement la vidéo et complétez la leçon pour débloquer la suite du cours.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        if (!_isCompleted)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 15, 64, 149),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isCompleted = true;
                                });
                                widget.onLessonCompleted();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Leçon complétée! La prochaine leçon est maintenant disponible.'),
                                  ),
                                );
                              },
                              child: const Text(
                                'Marquer comme terminé',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        if (_isCompleted)
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green),
                                    SizedBox(width: 8),
                                    Text(
                                      'Leçon terminée!',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              if (widget.onNextLesson != null)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade800,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      widget.onNextLesson!();
                                    },
                                    child: const Text(
                                      'Leçon suivante',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_updateProgress);
    _controller.dispose();
    super.dispose();
  }
}