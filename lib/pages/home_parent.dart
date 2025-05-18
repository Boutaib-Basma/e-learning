import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fl_chart/fl_chart.dart'; // Ajoutez cette dépendance à votre pubspec.yaml

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({Key? key}) : super(key: key);

  @override
  _ParentHomePageState createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  List<dynamic> _enfants = [];
  Map<int, dynamic> _studentDetails = {};
  bool _isLoading = true;
  
  // Couleurs principales
  final Color _primaryColor = const Color(0xFF6C63FF);
  final Color _secondaryColor = const Color(0xFFFF6584);
  final Color _lightBlueColor = const Color(0xFFE6EFFD);
  
  // Données d'activité 
  int _completionPercentage = 65;
  int _coursesCompleted = 12;
  int _totalCourses = 20;
  int _activityHours = 20;
  int _activityMinutes = 44;
  
  // Jours de la semaine pour le graphique
  final List<String> _weekdays = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
  
  // Données du graphique (heures d'étude par jour)
  final List<double> _weeklyActivity = [2.5, 3.7, 5.2, 9.5, 4.3, 3.1, 1.8];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      _fetchParentDetails();
    });
  }

  Future<void> _fetchParentDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final token = prefs.getString('authToken');
      log("User ID: $userId");
      if (userId == null || token == null) {
        throw Exception('Informations utilisateur non disponibles');
      }

      final HttpClient client = HttpClient()
        ..badCertificateCallback = 
            (X509Certificate cert, String host, int port) => true;
      
      final ioClient = IOClient(client);
      
      final response = await ioClient.get(
        Uri.parse('https://192.168.1.128:5001/api/Parents/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      log("Parent API Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final parentId = responseData['id']; // Extract the real parent ID
        log("Parent ID: $parentId");
        
        // Proceed to fetch children using the real parent ID
        await _fetchEnfants(parentId, token);
      } else {
        throw Exception('Échec du chargement des informations du parent');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchEnfants(int parentId, String token) async {
    try {
      final HttpClient client = HttpClient()
        ..badCertificateCallback = 
            (X509Certificate cert, String host, int port) => true;
      
      final ioClient = IOClient(client);
      
      final response = await ioClient.get(
        Uri.parse('https://192.168.1.128:5001/api/Parents/$parentId/Children'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      log("Children API Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        log("Children Data: $responseData");
        setState(() {
          _enfants = responseData;
        });
        
        for (var enfant in _enfants) {
          await _fetchStudentDetails(enfant['id'], token);
        }
        
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Échec du chargement des enfants');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchStudentDetails(int studentId, String token) async {
    try {
      final HttpClient client = HttpClient()
        ..badCertificateCallback = 
            (X509Certificate cert, String host, int port) => true;
      
      final ioClient = IOClient(client);
      
      final response = await ioClient.get(
        Uri.parse('https://192.168.1.128:5001/api/Students/$studentId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _studentDetails[studentId] = responseData;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération des détails de l\'étudiant: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchParentDetails,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEnfantsSection(),
                    const SizedBox(height: 12),
                    _buildProgressSection(),
                    const SizedBox(height: 24),
                    _buildActivitySection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              title: 'Completed',
              value: '$_completionPercentage%',
              color: const Color(0xFFE0F2F1),
              icon: Icons.check_circle_outline,
              iconColor: Colors.teal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              title: 'Course',
              value: '$_coursesCompleted/$_totalCourses',
              color: const Color(0xFFFCE4EC),
              icon: Icons.menu_book_outlined,
              iconColor: Colors.pink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your activity',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$_activityHours',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const Text(
                        'hr ',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$_activityMinutes',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const Text(
                        'min',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: _buildActivityChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    // Trouver l'index du jour avec la valeur maximale
    final maxValueIndex = _weeklyActivity.indexOf(
        _weeklyActivity.reduce((curr, next) => curr > next ? curr : next));
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: _weeklyActivity.reduce((curr, next) => curr > next ? curr : next) * 1.2,
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  _weekdays[value.toInt()],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          _weeklyActivity.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: _weeklyActivity[index],
                color: index == maxValueIndex ? _secondaryColor : Colors.grey[300],
                width: 12,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnfantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Mes Enfants',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _enfants.length,
          itemBuilder: (context, index) {
            return _buildSimpleEnfantCard(_enfants[index]);
          },
        ),
      ],
    );
  }

  Widget _buildSimpleEnfantCard(Map<String, dynamic> enfant) {
    final fullName = '${enfant['firstName'] ?? ''} ${enfant['lastName'] ?? ''}'.trim();
    final studentId = enfant['id'];
    final studentDetail = _studentDetails[studentId];
    final levelName = studentDetail?['levelName'] ?? 'Niveau non spécifié';
    final className = studentDetail?['className'] ?? 'Classe non spécifiée';

    // Attribution des couleurs selon le niveau
    Color levelColor;
    switch (levelName) {
      case 'Avancé':
        levelColor = const Color.fromARGB(255, 255, 255, 255);
        break;
      case 'Intermédiaire':
        levelColor = Colors.orange;
        break;
      case 'Débutant':
        levelColor = Colors.blue;
        break;
      default:
        levelColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Color.fromARGB(255, 0, 74, 173),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Initiales dans un cercle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  fullName.isNotEmpty 
                      ? fullName.split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join('')
                      : '?',
                  style: TextStyle(
                    color: levelColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            //Informations de l'enfant
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName.isNotEmpty ? fullName : 'Nom non disponible',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    className,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 213, 213, 213),
                    ),
                  ),
                ],
              ),
            ),
            // Badge de niveau
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: levelColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                levelName,
                style: TextStyle(
                  color: levelColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}