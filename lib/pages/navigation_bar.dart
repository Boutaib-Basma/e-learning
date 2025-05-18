import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:mon_elearning/pages/home_parent.dart';
import 'package:mon_elearning/pages/profile_page.dart';
import 'package:mon_elearning/pages/notification_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mon_elearning/pages/all_courses.dart';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:mon_elearning/pages/progres_eleve.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Article class for fetching articles from dev.to
class Article {
  final String title;
  final String description;
  final String url;

  Article({
    required this.title,
    required this.description,
    required this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'Sans titre',
      description: json['description'] ?? 'Pas de description',
      url: json['url'] ?? '',
    );
  }
}

// Course model to parse API response for courses progress
class CourseProgress {
  final int courseId;
  final String courseName;
  final int totalLessons;
  final int completedLessons;
  final double percentageCompleted;
  final bool isCourseCompleted;

  CourseProgress({
    required this.courseId,
    required this.courseName,
    required this.totalLessons,
    required this.completedLessons,
    required this.percentageCompleted,
    required this.isCourseCompleted,
  });

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      courseId: json['courseId'] ?? 0,
      courseName: json['courseName'] ?? 'Cours inconnu',
      totalLessons: json['totalLessons'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
      percentageCompleted: (json['percentageCompleted'] ?? 0).toDouble(),
      isCourseCompleted: json['isCourseCompleted'] ?? false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String userFirstName = 'Basma';
  late List<Widget> _pages;
  late Widget homePage;

  @override
  void initState() {
    log('User ID: ${widget.user['id']}');
    if (widget.user['role'] == 'student') {
      homePage = HomeContent(user: widget.user);
    } else {
      homePage = ParentHomePage();
    }
    _pages = [
      homePage,
      const AllCoursesPage(),
      ProfilePage(user: widget.user),
    ];
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: const Color.fromARGB(255, 255, 249, 245),
              elevation: 0,
              forceMaterialTransparency: true,
              titleSpacing: 0,
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 0, 74, 173),
                      radius: 20,
                      child: Text(
                        userFirstName.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Bonjour, ${widget.user['role'] == 'parents' ? 'Ghita' : userFirstName}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Container(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationPage(),
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 15, 64, 149),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: FluidNavBar(
        icons: [
          FluidNavBarIcon(
            icon: Icons.home,
            backgroundColor: const Color.fromARGB(255, 15, 64, 149),
          ),
          FluidNavBarIcon(
            icon: Icons.search,
            backgroundColor: const Color.fromARGB(255, 15, 64, 149),
          ),
          FluidNavBarIcon(
            icon: Icons.person,
            backgroundColor: const Color.fromARGB(255, 15, 64, 149),
          ),
        ],
        onChange: _onItemTapped,
        style: FluidNavBarStyle(
          barBackgroundColor: Colors.grey.shade200,
          iconBackgroundColor: Colors.white,
          iconSelectedForegroundColor: Colors.white,
          iconUnselectedForegroundColor: Colors.white.withOpacity(0.4),
        ),
        defaultIndex: _selectedIndex,
        animationFactor: 0.8,
        scaleFactor: 1.2,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomeContent({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Article> articles = [];
  List<CourseProgress> courses = [];
  bool isLoading = true;
  String? errorMessage;
  String _selectedCategory = 'Tous';
  int? _studentId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final articleResult = await _fetchArticles();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      log('Auth Token: ${token != null ? 'Found' : 'Not Found'}');
      if (token == null) {
        throw Exception('Token d\'authentification non disponible');
      }
      await _fetchStudentDetails(token);
      setState(() {
        articles = articleResult;
        isLoading = false;
      });
    } catch (e) {
      log('Error loading data: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchStudentDetails(String token) async {
    try {
      final client = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final ioClient = IOClient(client);

      final userId = widget.user['id'].toString();
      final response = await ioClient.get(
        Uri.parse('https://192.168.1.128:5001/api/Students/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      log('Student API Response Status: ${response.statusCode}');
      log('Student API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final studentId = responseData['id'];
        if (studentId == null) {
          throw Exception('Student ID not found in response');
        }
        setState(() {
          _studentId = studentId;
        });
        await _fetchCoursesProgress(studentId, token);
      } else {
        throw Exception('Échec du chargement des détails de l\'étudiant: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching student details: $e');
      setState(() {
        errorMessage = 'Erreur lors de la récupération des détails de l\'étudiant: ${e.toString()}';
      });
      rethrow;
    }
  }

  Future<List<Article>> _fetchArticles() async {
    try {
      final response = await http.get(
        Uri.parse('https://dev.to/api/articles'),
      ).timeout(const Duration(seconds: 10));

      log('Articles API Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        List jsonData = json.decode(response.body);
        return jsonData.map((item) => Article.fromJson(item)).toList();
      } else {
        log('Failed to load articles: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching articles: $e');
      return [];
    }
  }

  Future<void> _fetchCoursesProgress(int studentId, String token) async {
    try {
      final client = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final ioClient = IOClient(client);

      final response = await ioClient.get(
        Uri.parse('https://192.168.1.128:5001/api/LessonProgress/CoursesProgressByStudentAndLevel/$studentId/1'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      log('Courses Progress API Response Status: ${response.statusCode}');
      log('Courses Progress API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is! List) {
          throw Exception('Invalid courses progress response format: Expected a list');
        }
        setState(() {
          courses = responseData.map((item) => CourseProgress.fromJson(item)).toList();
          courses = courses.where((course) => !course.isCourseCompleted).toList();
          log('Filtered Courses Count: ${courses.length}');
        });
      } else {
        throw Exception('Échec du chargement de la progression des cours: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching courses progress: $e');
      setState(() {
        errorMessage = 'Erreur lors de la récupération de la progression des cours: ${e.toString()}';
      });
      rethrow;
    }
  }

  Future<void> _launchUrlInBrowser(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Impossible d\'ouvrir le lien: $url';
      }
    } catch (e) {
      log('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: Impossible d\'ouvrir le lien')),
      );
    }
  }

  List<CourseProgress> get _filteredCourses {
    if (_selectedCategory == 'Tous') {
      return courses;
    }
    return courses.where((course) => course.courseName == _selectedCategory).toList();
  }

  Widget _buildCategoryItem(String text, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 15, 64, 149) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? const Color.fromARGB(255, 255, 252, 100) : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final carouselHeight = MediaQuery.of(context).size.height * 0.25;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: carouselHeight,
              child: FlutterCarousel(
                options: FlutterCarouselOptions(
                  height: carouselHeight,
                  showIndicator: true,
                  slideIndicator: CircularSlideIndicator(),
                  viewportFraction: 0.95,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  padEnds: true,
                ),
                items: ['assets/images/b7.png', 'assets/images/b8.png'].map((imagePath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: screenWidth * 0.93,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage(imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryItem('Tous', isSelected: _selectedCategory == 'Tous'),
                        _buildCategoryItem('Flutter', isSelected: _selectedCategory == 'Flutter'),
                        _buildCategoryItem('Backend', isSelected: _selectedCategory == 'Backend'),
                        _buildCategoryItem('Design', isSelected: _selectedCategory == 'Design'),
                        _buildCategoryItem('Soft Skills', isSelected: _selectedCategory == 'Soft Skills'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mes cours en cours',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    errorMessage!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadData,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 15, 64, 149),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                                ],
                              ),
                            )
                          : _filteredCourses.isEmpty
                              ? const Center(child: Text('Aucun cours en cours'))
                              : Column(
                                  children: _filteredCourses.map((course) {
                                    final image = course.courseId % 2 == 0 ? 'assets/images/b7.png' : 'assets/images/b8.png';
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProgressElevePage(
                                              userId: widget.user['id'].toString(),
                                              courseId: course.courseId,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                image: DecorationImage(
                                                  image: AssetImage(image),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    course.courseName,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${course.completedLessons}/${course.totalLessons} leçons complétées',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(3),
                                                          child: LinearProgressIndicator(
                                                            value: course.percentageCompleted / 100,
                                                            backgroundColor: Colors.grey[200],
                                                            valueColor: const AlwaysStoppedAnimation<Color>(
                                                                Color.fromARGB(255, 87, 211, 87)),
                                                            minHeight: 6,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        '${course.percentageCompleted.toStringAsFixed(0)}%',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey[600],
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
                                  }).toList(),
                                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}