import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'course_content.dart';

class ProgressElevePage extends StatefulWidget {
  final String userId;
  final int courseId;

  const ProgressElevePage({Key? key, required this.userId, required this.courseId}) : super(key: key);

  @override
  _ProgressElevePageState createState() => _ProgressElevePageState();
}

class _ProgressElevePageState extends State<ProgressElevePage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _lessonProgress = [];
  String _studentName = '';
  int? _studentId;
  String _courseName = '';
  String _courseDescription = '';
  String _formateur = '';
  String _imageCourse = '';

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) {
        throw Exception('Token d\'authentification non disponible');
      }

      final HttpClient client = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      final ioClient = IOClient(client);

      final response = await ioClient.get(
        Uri.parse('https://192.168.1.128:5001/api/Students/user/${widget.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      log("Student API Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _studentId = responseData['id'];
          _studentName =
              '${responseData['user']['firstName']} ${responseData['user']['lastName']}';
        });
        await Future.wait([
          _fetchCourseDetails(token),
          _fetchLessonProgress(token),
        ]);
      } else {
        throw Exception('Échec du chargement des détails de l\'étudiant');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchCourseDetails(String token) async {
    try {
      final HttpClient client = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      final ioClient = IOClient(client);

      final response = await ioClient.get(
        Uri.parse('https://192.168.1.128:5001/api/Course/${widget.courseId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      log("Course API Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _courseName = responseData['courseName'] ?? 'Cours non spécifié';
          _courseDescription =
              responseData['courseDescription'] ?? 'Aucune description disponible.';
          _formateur = responseData['formateur'] ?? 'Formateur non spécifié';
          _imageCourse = responseData['imageCourse'] ?? '';
        });
      } else {
        throw Exception('Échec du chargement des détails du cours');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement du cours: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchLessonProgress(String token) async {
    try {
      final HttpClient client = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      final ioClient = IOClient(client);

      final response = await ioClient.get(
        Uri.parse('https://192.168.1.128:5001/course/${widget.courseId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      log("Lesson Progress API Response Status: ${response.statusCode}");
      log("Lesson Progress API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          _lessonProgress = responseData.map((lesson) {
            return {
              'lessonId': lesson['lessonId'] ?? 0,
              'titre': lesson['titre'] ?? 'Leçon sans nom',
              'videoUrl': lesson['url'] ?? '',
              'description': lesson['description'] ?? 'Aucune description disponible',
              'duration': lesson['duration'] ?? '00:00:00',
              'isCompleted': false,
              'lastSecond': 0,
            };
          }).toList();
          _isLoading = false;
        });
        // Log video URLs for debugging
        for (var lesson in _lessonProgress) {
          log("Lesson: ${lesson['titre']}, videoUrl: ${lesson['videoUrl']}");
        }
      } else {
        throw Exception('Échec du chargement des progrès des leçons');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur: ${e.toString()}';
      });
    }
  }

  int _parseDurationToSeconds(String duration) {
    try {
      final parts = duration.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final seconds = int.parse(parts[2]);
      return hours * 3600 + minutes * 60 + seconds;
    } catch (e) {
      return 0;
    }
  }

  double _calculateProgressPercentage(int lastSecond, String duration) {
    final totalSeconds = _parseDurationToSeconds(duration);
    if (totalSeconds == 0) return 0.0;
    return (lastSecond / totalSeconds).clamp(0.0, 1.0) * 100;
  }

  int get completedLessons => _lessonProgress.where((l) => l['isCompleted'] == true).length;

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
          'Progrès de l\'élève',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _errorMessage = null;
                              });
                              _fetchStudentDetails();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 15, 64, 149),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Réessayer',
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
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: Container(
                          height: 220,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: _imageCourse.isNotEmpty
                              ? Image.network(
                                  _imageCourse,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text(
                                        'Erreur de chargement de l\'image',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Text(
                                    'Image non disponible',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
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
                                    _courseName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Formateur: $_formateur',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
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
                                        '$completedLessons/${_lessonProgress.length} leçons',
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
                                      value: _lessonProgress.isEmpty
                                          ? 0
                                          : completedLessons / _lessonProgress.length,
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
                              _courseDescription,
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
                            ..._lessonProgress.asMap().entries.map((entry) {
                              final index = entry.key;
                              final lesson = entry.value;
                              return _buildLessonItem(
                                context,
                                lesson['titre'] ?? 'Leçon sans nom',
                                true,
                                lesson['isCompleted']
                                    ? Icons.check_circle
                                    : Icons.play_circle_fill,
                                index,
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
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Retour',
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
      BuildContext context, String title, bool isUnlocked, IconData icon, int index) {
    final lesson = _lessonProgress[index];
    final progressPercentage = _calculateProgressPercentage(
      lesson['lastSecond'] ?? 0,
      lesson['duration'] ?? '00:00:00',
    );
    final videoUrl = lesson['videoUrl'] as String?;

    return GestureDetector(
      onTap: () {
        if (videoUrl == null || videoUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur: Aucune URL de vidéo disponible pour cette leçon.'),
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseContentPage(
              lessonTitle: lesson['titre'] ?? 'Leçon sans nom',
              courseTitle: _courseName,
              videoUrl: videoUrl,
              lessonDescription: lesson['description'] ?? 'Aucune description disponible',
              lessonDuration: lesson['duration'] ?? '00:00:00',
              studentId: _studentId,
              lessonId: lesson['lessonId'] ?? 0,
              courseId: widget.courseId,
              onLessonCompleted: () {
                setState(() {
                  _lessonProgress[index]['isCompleted'] = true;
                });
              },
              onNextLesson: index < _lessonProgress.length - 1
                  ? () {
                      final nextLesson = _lessonProgress[index + 1];
                      final nextVideoUrl = nextLesson['videoUrl'] as String?;
                      if (nextVideoUrl == null || nextVideoUrl.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erreur: Aucune URL de vidéo disponible pour la leçon suivante.'),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseContentPage(
                            lessonTitle: nextLesson['titre'] ?? 'Leçon sans nom',
                            courseTitle: _courseName,
                            videoUrl: nextVideoUrl,
                            lessonDescription: nextLesson['description'] ?? 'Aucune description disponible',
                            lessonDuration: nextLesson['duration'] ?? '00:00:00',
                            studentId: _studentId,
                            lessonId: nextLesson['lessonId'] ?? 0,
                            courseId: widget.courseId,
                            onLessonCompleted: () {
                              setState(() {
                                _lessonProgress[index + 1]['isCompleted'] = true;
                              });
                            },
                            onNextLesson: index + 1 < _lessonProgress.length - 1
                                ? () {
                                    final nextNextLesson = _lessonProgress[index + 2];
                                    final nextNextVideoUrl = nextNextLesson['videoUrl'] as String?;
                                    if (nextNextVideoUrl == null || nextNextVideoUrl.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Erreur: Aucune URL de vidéo disponible pour la leçon suivante.'),
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CourseContentPage(
                                          lessonTitle: nextNextLesson['titre'] ?? 'Leçon sans nom',
                                          courseTitle: _courseName,
                                          videoUrl: nextNextVideoUrl,
                                          lessonDescription: nextNextLesson['description'] ??
                                              'Aucune description disponible',
                                          lessonDuration: nextNextLesson['duration'] ?? '00:00:00',
                                          studentId: _studentId,
                                          lessonId: nextNextLesson['lessonId'] ?? 0,
                                          courseId: widget.courseId,
                                          onLessonCompleted: () {
                                            setState(() {
                                              _lessonProgress[index + 2]['isCompleted'] = true;
                                            });
                                          },
                                          onNextLesson: index + 2 < _lessonProgress.length - 1
                                              ? () {
                                                  Navigator.pop(context);
                                                }
                                              : null,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ),
        );
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
                  ? const Color.fromARGB(255, 87, 211, 87)
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
                  const SizedBox(height: 4),
                  Text(
                    'Progrès: ${progressPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isUnlocked)
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