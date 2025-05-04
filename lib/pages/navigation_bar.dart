import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:http/http.dart' as http;
import 'package:mon_elearning/pages/profile_page.dart';
import 'package:mon_elearning/pages/notification_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mon_elearning/pages/all_courses.dart';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';

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

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String userFirstName = 'Basma';
  late List<Widget> _pages = [];

  @override
  void initState() {
    _pages = [
      const HomeContent(),
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
              titleSpacing: 0, // Remove default title spacing
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16), // Match horizontal padding with content below
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 0, 74, 173),
                      radius: 20,
                      child: Text(
                        userFirstName.substring(0, 1),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 252, 100),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Bonjour, ${widget.user['role'] == 'parents' ? 'Ghita' : '$userFirstName'} ',
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
                  padding: const EdgeInsets.only(right: 16), // Same right padding as content below
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
                      width: 40, // Fixed width for consistent sizing
                      height: 40, // Fixed height to match avatar size
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
                        color: Color.fromARGB(255, 255, 252, 100),
                        size: 24, // Consistent icon size
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
          iconBackgroundColor: const Color.fromARGB(255, 254, 255, 255),
          iconSelectedForegroundColor: const Color.fromARGB(255, 255, 252, 100),
          iconUnselectedForegroundColor: const Color.fromARGB(255, 255, 252, 100).withOpacity(0.6),
        ),
        defaultIndex: _selectedIndex,
        animationFactor: 0.8,
        scaleFactor: 1.2,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Article> articles = [];
  bool isLoading = true;
  String _selectedCategory = 'Tous';

  final List<Map<String, dynamic>> _courses = [
    {
      'title': 'Arts & Crafts',
      'description': 'How to make tubes and paper crafts',
      'image': 'assets/images/b7.png',
      'category': 'Design',
      'progress': 3 / 9,
      'lessons': '3 of 9 lessons',
    },
    {
      'title': 'Robotics',
      'description': 'Arduino Robotics with mBot',
      'image': 'assets/images/b8.png',
      'category': 'Backend',
      'progress': 5 / 8,
      'lessons': '5 of 8 lessons',
    },
    {
      'title': 'Mathematics',
      'description': 'Algorithms with python',
      'image': 'assets/images/b7.png',
      'category': 'Backend',
      'progress': 5 / 8,
      'lessons': '5 of 8 lessons',
    },
  ];

  @override
  void initState() {
    super.initState();
    loadArticles();
  }

  Future<void> loadArticles() async {
    try {
      final result = await fetchArticles();
      setState(() {
        articles = result;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Article>> fetchArticles() async {
    final response = await http.get(
      Uri.parse('https://dev.to/api/articles'),
    );

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((item) => Article.fromJson(item)).toList();
    } else {
      throw Exception('Échec du chargement des articles');
    }
  }

  Future<void> launchUrlInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossible d\'ouvrir le lien $url';
    }
  }

  List<Map<String, dynamic>> get _filteredCourses {
    if (_selectedCategory == 'Tous') {
      return _courses;
    }
    return _courses.where((course) => course['category'] == _selectedCategory).toList();
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7),
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
                  ..._filteredCourses.map((course) {
                    return Container(
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
                                image: AssetImage(course['image']),
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
                                  course['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  course['description'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: LinearProgressIndicator(
                                          value: course['progress'],
                                          backgroundColor: Colors.grey[200],
                                          valueColor: const AlwaysStoppedAnimation<Color>(
                                              Color.fromARGB(255, 87, 211, 87)),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      course['lessons'],
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
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}