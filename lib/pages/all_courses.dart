import 'package:flutter/material.dart';
import 'detail_page.dart';

class AllCoursesPage extends StatefulWidget {
  const AllCoursesPage({Key? key}) : super(key: key);

  @override
  _AllCoursesPageState createState() => _AllCoursesPageState();
}

class _AllCoursesPageState extends State<AllCoursesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _courses = [
    {
      'title': "Introduction à Flutter",
      'description': "Découvrez les bases de Flutter pour le développement multiplateforme.",
      'imageUrl': "assets/images/b7.png",
      'category': "UI",
    },
    {
      'title': "Les meilleures pratiques en UI/UX",
      'description': "Apprenez à créer des interfaces utilisateur intuitives et esthétiques.",
      'imageUrl': "assets/images/b8.png",
      'category': "UI",
    },
    {
      'title': "Développement backend avec Node.js",
      'description': "Créez des APIs robustes avec Node.js et Express.",
      'imageUrl': "assets/images/b7.png",
      'category': "Business",
    },
    {
      'title': "Gestion de state avec Provider",
      'description': "Maîtrisez la gestion d'état dans vos applications Flutter.",
      'imageUrl': "assets/images/b8.png",
      'category': "UX",
    },
    {
      'title': "Marketing digital pour débutants",
      'description': "Apprenez les bases du marketing digital et des réseaux sociaux.",
      'imageUrl': "assets/images/b7.png",
      'category': "Marketing",
    },
    {
      'title': "Yoga et méditation",
      'description': "Découvrez comment améliorer votre bien-être quotidien.",
      'imageUrl': "assets/images/b8.png",
      'category': "Lifestyle",
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'UI', 'count': '25+ Courses', 'icon': Icons.design_services, 'color': const Color(0xFFFFF2E6)},
    {'name': 'Business', 'count': '80+ Courses', 'icon': Icons.business, 'color': const Color(0xFFE6F7FF)},
    {'name': 'Lifestyle', 'count': '120+ Courses', 'icon': Icons.spa, 'color': const Color(0xFFF0FFE6)},
    {'name': 'Marketing', 'count': '50+ Courses', 'icon': Icons.trending_up, 'color': const Color(0xFFFFE6F7)},
    {'name': 'UX', 'count': '145+ Courses', 'icon': Icons.psychology, 'color': const Color(0xFFF0E6FF)},
    {'name': 'Social', 'count': '15+ Courses', 'icon': Icons.people, 'color': const Color(0xFFFFF7E6)},
  ];

  List<Map<String, dynamic>> get _filteredCourses {
    return _courses.where((course) {
      final matchesCategory = _selectedCategory.isEmpty || course['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          course['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course['description'].toLowerCase().contains(_searchQuery.toLowerCase());
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
      appBar: AppBar(
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
            SizedBox(
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
                        _selectedCategory = _selectedCategory == category['name'] ? '' : category['name'];
                      });
                    },
                    child: _buildCategoryItem(
                      category['name'],
                      category['count'],
                      category['icon'],
                      category['color'],
                      isSelected: _selectedCategory == category['name'],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Toutes les formations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_filteredCourses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Aucun cours trouvé',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              ..._filteredCourses.map((course) {
                return Column(
                  children: [
                    _buildArticleCard(
                      context: context,
                      title: course['title'],
                      description: course['description'],
                      imageUrl: course['imageUrl'],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String category, String coursesCount, IconData icon, Color backgroundColor, {bool isSelected = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? backgroundColor.withOpacity(0.7) : backgroundColor,
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
            ? Border.all(color: _getIconColor(backgroundColor), width: 2)
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
              child: Icon(icon, color: _getIconColor(backgroundColor), size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(coursesCount, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
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
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
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
                              imageUrl: imageUrl,
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