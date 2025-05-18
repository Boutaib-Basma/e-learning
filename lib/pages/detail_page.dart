import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';
import 'dart:convert';
import './course_content.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String instructor;
  final double rating;
  final int lessonCount;
  final int courseId;

  const DetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.instructor = "John Doe",
    this.rating = 4.5,
    this.lessonCount = 10,
    required this.courseId,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<Map<String, dynamic>> _lessons = [];
  bool _isLoadingLessons = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    try {
      final HttpClient client = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      final ioClient = IOClient(client);

      final response = await ioClient.get(
        Uri.parse('https://192.168.1.128:5001/course/${widget.courseId}'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> lessonsData = json.decode(response.body);

        setState(() {
          _lessons = lessonsData.map((lesson) {
            String url = lesson['url'] ?? '';
            bool isValidYouTubeUrl = YoutubePlayer.convertUrlToId(url) != null;
            return {
              'lessonId': lesson['lessonId'] ?? 0,
              'title': lesson['titre'] ?? 'Leçon sans titre',
              'unlocked': _lessons.isEmpty ? true : false,
              'completed': false,
              'url': url,
              'description': lesson['description'] ?? 'Aucune description disponible',
              'duration': lesson['duration'] ?? 'Durée inconnue',
              'isValidUrl': isValidYouTubeUrl,
            };
          }).toList();
          if (_lessons.any((lesson) => !lesson['isValidUrl'])) {
            _errorMessage = 'Certaines leçons ont des URLs YouTube invalides';
          }
          _isLoadingLessons = false;
        });
      } else {
        setState(() {
          _isLoadingLessons = false;
          _errorMessage = 'Erreur de chargement des leçons: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLessons = false;
        _errorMessage = 'Erreur de connexion: $e';
      });
    }
  }

  int get completedLessons => _lessons.where((l) => l['completed']).length;

  void _unlockNextLesson(int currentIndex) {
    if (currentIndex < _lessons.length - 1) {
      setState(() {
        _lessons[currentIndex]['completed'] = true;
        _lessons[currentIndex + 1]['unlocked'] = true;
      });
    } else if (currentIndex == _lessons.length - 1) {
      setState(() {
        _lessons[currentIndex]['completed'] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        title: Text(
          'Détails de la formation',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image.asset(
                widget.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 87, 211, 87),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.rating.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Par ${widget.instructor}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progression',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              '$completedLessons/${_lessons.length} leçons',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: _lessons.isEmpty
                                ? 0
                                : completedLessons / _lessons.length,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 87, 211, 87)),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 24, bottom: 12),
                    child: Text(
                      'Leçons',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isLoadingLessons)
                    const Center(child: CircularProgressIndicator())
                  else if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    )
                  else if (_lessons.isEmpty)
                    const Text('Aucune leçon disponible')
                  else
                    ..._lessons.asMap().entries.map((entry) {
                      final index = entry.key;
                      final lesson = entry.value;
                      return _buildLessonItem(
                        context,
                        lesson['title'],
                        lesson['unlocked'],
                        lesson['completed'] ? Icons.check_circle : Icons.play_circle_fill,
                        index,
                        lesson['isValidUrl'],
                      );
                    }).toList(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 15, 64, 149),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _lessons.isEmpty
                      ? null
                      : () {
                          final nextLesson = _lessons.firstWhere(
                            (l) => l['unlocked'] && !l['completed'],
                            orElse: () => _lessons.last,
                          );

                          if (nextLesson['unlocked']) {
                            if (nextLesson['isValidUrl']) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseContentPage(
                                    lessonTitle: nextLesson['title'],
                                    courseTitle: widget.title,
                                    videoUrl: nextLesson['url'],
                                    lessonDescription: nextLesson['description'],
                                    lessonDuration: nextLesson['duration'],
                                    lessonId: nextLesson['lessonId'],
                                    courseId: widget.courseId,
                                    onLessonCompleted: () => _unlockNextLesson(_lessons.indexOf(nextLesson)),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('URL de la leçon invalide. Veuillez vérifier.'),
                                ),
                              );
                            }
                          }
                        },
                  child: const Text(
                    'Continuer la formation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonItem(
    BuildContext context,
    String title,
    bool isUnlocked,
    IconData icon,
    int index,
    bool isValidUrl,
  ) {
    return GestureDetector(
      onTap: isUnlocked && isValidUrl
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseContentPage(
                    lessonTitle: title,
                    courseTitle: widget.title,
                    videoUrl: _lessons[index]['url'],
                    lessonDescription: _lessons[index]['description'],
                    lessonDuration: _lessons[index]['duration'],
                    lessonId: _lessons[index]['lessonId'],
                    courseId: widget.courseId,
                    onLessonCompleted: () => _unlockNextLesson(index),
                  ),
                ),
              );
            }
          : () {
              if (isUnlocked && !isValidUrl) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('URL de la leçon invalide. Veuillez vérifier.'),
                  ),
                );
              }
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isUnlocked
                  ? (isValidUrl
                      ? const Color.fromARGB(255, 87, 211, 87)
                      : Colors.red)
                  : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isUnlocked ? Colors.black : Colors.grey[500],
                    ),
                  ),
                  if (_lessons[index]['duration'] != null)
                    Text(
                      _lessons[index]['duration'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  if (!isValidUrl)
                    const Text(
                      'URL invalide',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
            if (isUnlocked && isValidUrl)
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}