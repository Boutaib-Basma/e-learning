class Lesson {
  final int lessonId;
  final String titre;
  final String url;
  final String duration;
  final String description;
  final int courseId;

  Lesson({
    required this.lessonId,
    required this.titre,
    required this.url,
    required this.duration,
    required this.description,
    required this.courseId,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lessonId'],
      titre: json['titre'],
      url: json['url'],
      duration: json['duration'],
      description: json['description'],
      courseId: json['courseId'],
    );
  }
}
