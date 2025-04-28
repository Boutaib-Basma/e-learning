import 'package:flutter/material.dart';
import './course_content.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String instructor;
  final double rating;
  final int lessonCount;

  const DetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.instructor = "John Doe",
    this.rating = 4.5,
    this.lessonCount = 10,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // Liste des leçons avec leur état de déverrouillage
  final List<Map<String, dynamic>> _lessons = [
    {'title': 'Introduction', 'unlocked': true, 'completed': false},
    {'title': 'Installation', 'unlocked': true, 'completed': false},
    {'title': 'Premiers pas', 'unlocked': false, 'completed': false},
    {'title': 'Widgets', 'unlocked': false, 'completed': false},
    {'title': 'State', 'unlocked': false, 'completed': false},
  ];

  int get completedLessons => _lessons.where((l) => l['completed']).length;

  // Fonction pour débloquer la leçon suivante
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
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
                              '$completedLessons/${widget.lessonCount} leçons',
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
                            value: completedLessons / widget.lessonCount,
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
                  ..._lessons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final lesson = entry.value;
                    return _buildLessonItem(
                      context,
                      lesson['title'],
                      lesson['unlocked'],
                      lesson['completed'] ? Icons.check_circle : Icons.play_circle_fill,
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
                    // Trouver la première leçon non complétée et déverrouillée
                    final nextLesson = _lessons.firstWhere(
                      (l) => l['unlocked'] && !l['completed'],
                      orElse: () => _lessons.last,
                    );
                    
                    if (nextLesson['unlocked']) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseContentPage(
                            lessonTitle: nextLesson['title'],
                            courseTitle: widget.title,
                            onLessonCompleted: () => _unlockNextLesson(_lessons.indexOf(nextLesson)),
                          ),
                        ),
                      );
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

  Widget _buildLessonItem(BuildContext context, String title, bool isUnlocked, IconData icon, int index) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseContentPage(
                    lessonTitle: title,
                    courseTitle: widget.title,
                    onLessonCompleted: () => _unlockNextLesson(index),
                  ),
                ),
              );
            }
          : null,
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
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isUnlocked ? Colors.black : Colors.grey[500],
                ),
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