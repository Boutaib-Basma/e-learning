class UserCourseProgress {
  final int courseId;
  final String courseName;
  final int totalLessons;
  final int completedLessons;
  final double percentageCompleted;
  final bool isCourseCompleted;

  UserCourseProgress({
    required this.courseId,
    required this.courseName,
    required this.totalLessons,
    required this.completedLessons,
    required this.percentageCompleted,
    required this.isCourseCompleted,
  });

  factory UserCourseProgress.fromJson(Map<String, dynamic> json) {
    return UserCourseProgress(
      courseId: json['courseId'],
      courseName: json['courseName'],
      totalLessons: json['totalLessons'],
      completedLessons: json['completedLessons'],
      percentageCompleted: (json['percentageCompleted'] as num).toDouble(),
      isCourseCompleted: json['isCourseCompleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'percentageCompleted': percentageCompleted,
      'isCourseCompleted': isCourseCompleted,
    };
  }
}
