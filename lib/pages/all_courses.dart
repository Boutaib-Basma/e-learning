import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';
import 'dart:convert';
import 'detail_page.dart';

class Category {
  final int id;
  final String name;
  final IconData icon;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['categoryName'] as String,
      icon: _getIconFromName(json['categoryName'] ?? ''),
      color: _getColorFromName(json['categoryName'] ?? ''),
    );
  }

  static IconData _getIconFromName(String name) {
    switch (name.toLowerCase()) {
      case 'ui':
        return Icons.design_services;
      case 'business':
        return Icons.business;
      case 'lifestyle':
        return Icons.spa;
      case 'marketing':
        return Icons.trending_up;
      case 'ux':
        return Icons.psychology;
      case 'social':
        return Icons.people;
      default:
        return Icons.category;
    }
  }

  static Color _getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'ui':
        return const Color(0xFFFFF2E6);
      case 'business':
        return const Color(0xFFE6F7FF);
      case 'lifestyle':
        return const Color(0xFFF0FFE6);
      case 'marketing':
        return const Color(0xFFFFE6F7);
      case 'ux':
        return const Color(0xFFF0E6FF);
      case 'social':
        return const Color(0xFFFFF7E6);
      default:
        return const Color(0xFFE6E6E6);
    }
  }
}

class Course {
  final int id;
  final String courseName;
  final String courseDescription;
  final String duration;
  final String level;
  final String imageCourse;
  final String formateur;
  final int formateurId;
  final String category;
  final DateTime created;
  final DateTime updated;

  Course({
    required this.id,
    required this.courseName,
    required this.courseDescription,
    required this.duration,
    required this.level,
    required this.imageCourse,
    required this.formateur,
    required this.formateurId,
    required this.category,
    required this.created,
    required this.updated,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      courseName: json['courseName'] ?? 'No Title',
      courseDescription: json['courseDescription'] ?? 'No Description',
      duration: json['duration'] ?? 'Unknown',
      level: json['level'] ?? 'Unknown',
      imageCourse: json['imageCourse'] ?? 'assets/images/b7.png',
      formateur: json['formateur'] ?? 'Unknown',
      formateurId: json['formateurId'] ?? 0, // Corrected typo: 'fourmateurId' to 'formateurId'
      category: json['category'] ?? 'Unknown',
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseName': courseName,
      'courseDescription': courseDescription,
      'duration': duration,
      'level': level,
      'imageCourse': imageCourse,
      'formateur': formateur,
      'formateurId': formateurId,
      'category': category,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}

class AllCoursesPage extends StatefulWidget {
  const AllCoursesPage({Key? key}) : super(key: key);

  @override
  _AllCoursesPageState createState() => _AllCoursesPageState();
}

class _AllCoursesPageState extends State<AllCoursesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';
  String _searchQuery = '';
  List<Category> _categories = [];
  List<Course> _courses = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final HttpClient client = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      final ioClient = IOClient(client);

      // Fetch categories
      final categoriesResponse = await ioClient.get(
        Uri.parse('https://192.168.1.128:5001/api/Category'),
        headers: {'Accept': 'application/json'},
      );
      print('Statut des catégories : ${categoriesResponse.statusCode}');
      print('Corps des catégories : ${categoriesResponse.body}');

      if (categoriesResponse.statusCode == 200) {
        final List<dynamic> decoded = json.decode(categoriesResponse.body);
        final List<Category> categoriesDataList =
            decoded.map((json) => Category.fromJson(json as Map<String, dynamic>)).toList();

        setState(() {
          _categories = categoriesDataList;
        });

        // Fetch courses
        final coursesResponse = await ioClient.get(
          Uri.parse('https://192.168.1.128:5001/api/Course'),
          headers: {'Accept': 'application/json'},
        );
        print('Statut des cours : ${coursesResponse.statusCode}');
        print('Corps des cours : ${coursesResponse.body}');

        if (coursesResponse.statusCode == 200) {
          final dynamic coursesDecoded = json.decode(coursesResponse.body);
          List<dynamic> coursesData;
          if (coursesDecoded is List) {
            coursesData = coursesDecoded;
          } else if (coursesDecoded is Map) {
            coursesData = coursesDecoded['courses'] ?? coursesDecoded['data'] ?? [];
          } else {
            coursesData = [];
          }
          setState(() {
            _courses = coursesData.map((json) => Course.fromJson(json)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Erreur de chargement des cours : ${coursesResponse.statusCode}';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur de chargement des catégories : ${categoriesResponse.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur de connexion : $e';
      });
    }
  }

  List<Course> get _filteredCourses {
    return _courses.where((course) {
      final matchesCategory = _selectedCategory.isEmpty || course.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          course.courseName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.courseDescription.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search courses, skills and videos',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
              suffixIcon: IconButton(
                icon: Icon(Icons.mic, color: Colors.grey[500], size: 20),
                onPressed: () {},
              ),
            ),
            style: const TextStyle(fontSize: 14),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCategoriesSection(),
            const SizedBox(height: 24),
            const Text(
              'Toutes les formations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCoursesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          children: [
            Text(_errorMessage),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
        children: _categories.map((category) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = _selectedCategory == category.name ? '' : category.name;
              });
            },
            child: _buildCategoryItem(category),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    final isSelected = _selectedCategory == category.name;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? category.color.withOpacity(0.7) : category.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        border: isSelected
            ? Border.all(color: _getIconColor(category.color), width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(category.icon, color: _getIconColor(category.color), size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          children: [
            Text(_errorMessage),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_filteredCourses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Aucun cours trouvé',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: _filteredCourses.map((course) {
        return Column(
          children: [
            _buildArticleCard(
              context: context,
              title: course.courseName,
              description: course.courseDescription,
              imageUrl: course.imageCourse,
              courseId: course.id, // Pass courseId
              instructor: course.formateur, // Pass formateur as instructor
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Color _getIconColor(Color backgroundColor) {
    if (backgroundColor == const Color(0xFFFFF2E6)) return Colors.orange;
    if (backgroundColor == const Color(0xFFE6F7FF)) return Colors.blue;
    if (backgroundColor == const Color(0xFFF0FFE6)) return Colors.green;
    if (backgroundColor == const Color(0xFFFFE6F7)) return Colors.pink;
    if (backgroundColor == const Color(0xFFF0E6FF)) return Colors.purple;
    return Colors.amber;
  }

  Widget _buildArticleCard({
    required BuildContext context,
    required String title,
    required String description,
    required String imageUrl,
    required int courseId, // Add courseId parameter
    required String instructor, // Add instructor parameter
  }) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imageUrl.startsWith('assets/') ? imageUrl : 'assets/images/b7.png',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPage(
                              title: title,
                              description: description,
                              imageUrl: imageUrl.startsWith('assets/') ? imageUrl : 'assets/images/b7.png',
                              instructor: instructor, // Pass instructor
                              courseId: courseId, // Pass courseId
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Lire plus',
                        style: TextStyle(
                          color: Color.fromARGB(255, 15, 64, 149),
                          fontWeight: FontWeight.bold,
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
    );
  }
}