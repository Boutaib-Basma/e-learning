import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mon_elearning/pages/models/lesson.dart';
import 'package:mon_elearning/pages/models/lesson_progress.dart';
import 'package:mon_elearning/pages/models/user_course_progress.dart';

final baseUrl = "https://192.168.1.128:5001/api/";
class ProgressService {
  // elle nous apporte les cours en cours avec le progres pour chaque etudiant
  Future<List<UserCourseProgress>> fetchUserCourseProgress(int id) async {
  final response = await http.get(Uri.parse('${baseUrl}LessonProgress/student/$id')); // Replace with your URL

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((json) => UserCourseProgress.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load user course progress');
  }
}
// 
Future<List<LessonProgress>> fetchLessonProgress(int studentId) async {
  final response = await http.get(Uri.parse('${baseUrl}LessonProgress/$studentId')); // Replace with actual URL

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((json) => LessonProgress.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load lesson progress');
  }
}

Future<List<Lesson>> fetchLessons(int courseId) async {
  final response = await http.get(Uri.parse('${baseUrl}Lesson/LessonById/$courseId')); // Replace with your API URL

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((json) => Lesson.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load lessons');
  }
}
}


