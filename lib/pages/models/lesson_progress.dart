class LessonProgress {
  final int id;
  final int studentId;
  final String studentName;
  final int lessonId;
  final int courseId;
  final String courseName;
  final bool isCompleted;
  final String lessonName;
  final int lastSecond;
  final DateTime updatedAt;

  LessonProgress({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.lessonId,
    required this.courseId,
    required this.courseName,
    required this.isCompleted,
    required this.lessonName,
    required this.lastSecond,
    required this.updatedAt,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      lessonId: json['lessonId'],
      courseId: json['courseId'],
      courseName: json['courseName'],
      isCompleted: json['isCompleted'],
      lessonName: json['lessonName'],
      lastSecond: json['lastSecond'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
