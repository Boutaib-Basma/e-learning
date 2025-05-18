import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

enum Role { parents, students }

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Role role;

  const ProfilePage({
    Key? key, 
    required this.user, 
    this.role = Role.students
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final token = prefs.getString('authToken');

      if (userId == null || token == null) {
        throw Exception('Informations utilisateur non disponibles');
      }

      final HttpClient client = HttpClient()
        ..badCertificateCallback = 
            (X509Certificate cert, String host, int port) => true;
      
      final ioClient = IOClient(client);
      
      final response = await ioClient.get(
        Uri.parse('https://192.168.1.128:5001/api/Users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          userDetails = responseData;
          _isLoading = false;
        });
      } else {
        throw Exception('Échec du chargement des informations utilisateur');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = userDetails ?? widget.user;
    final fullName = user['firstName'] != null && user['lastName'] != null
        ? '${user['firstName']} ${user['lastName']}'
        : user['name'] ?? 'Utilisateur';
    
    final role = user['roleName'] != null 
        ? (user['roleName'].toString().toLowerCase() == 'parent' 
            ? Role.parents 
            : Role.students)
        : widget.role;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Erreur: $_errorMessage'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(context, fullName, role),
                      const SizedBox(height: 12),
                      _buildSectionTitle('Paramètres du compte'),
                      _buildRoleSpecificMenuItems(context, role),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, Role role) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAFF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 45,
                color: Color(0xFF8687E7),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 2),
              Text(
                userDetails?['email'] ?? widget.user['email'] ?? 'Email non disponible',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: role == Role.students 
                  ? const Color(0xFFE0F7EF) 
                  : const Color(0xFFEEDCFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  role == Role.students 
                      ? Icons.school_outlined 
                      : Icons.family_restroom,
                  size: 16,
                  color: role == Role.students 
                      ? const Color(0xFF26A69A) 
                      : const Color(0xFF9C27B0),
                ),
                const SizedBox(width: 4),
                Text(
                  role == Role.students ? 'Élève' : 'Parent',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: role == Role.students 
                        ? const Color(0xFF26A69A) 
                        : const Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildRoleSpecificMenuItems(BuildContext context, Role role) {
    // Options spécifiques aux étudiants
    final List<Map<String, dynamic>> studentItems = [
      {
        'icon': Icons.school_outlined,
        'title': 'Cours accomplis',
        'color': const Color(0xFFE0F7EF),
        'iconColor': const Color(0xFF26A69A),
        'onTap': () {
          // Navigation vers la page des cours accomplis
        }
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Emploi du temps',
        'color': const Color(0xFFFFEFEB),
        'iconColor': const Color(0xFFFF8A65),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Emploi du temps'),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                ),
                body: _buildStudentCalendar(),
              ),
            ),
          );
        }
      },
    ];

    // Options spécifiques aux parents
    final List<Map<String, dynamic>> parentItems = [
      {
        'icon': Icons.family_restroom,
        'title': 'Mes enfants',
        'color': const Color(0xFFEEDCFF),
        'iconColor': const Color(0xFF9C27B0),
        'onTap': () {
          Navigator.pushNamed(context, '/mes_enfants');
        }
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Emploi du temps',
        'color': const Color(0xFFE0F2FF),
        'iconColor': const Color(0xFF2196F3),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Emploi du temps'),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                ),
                body: _buildStudentCalendar(),
              ),
            ),
          );
        }
      },
    ];

    // Option de déconnexion
    final Map<String, dynamic> logoutItem = {
      'icon': Icons.logout,
      'title': 'Déconnexion',
      'color': const Color(0xFFFFE0E0),
      'iconColor': const Color(0xFFEF5350),
      'onTap': () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.of(context).pushReplacementNamed('/login');
      }
    };

    // Combinaison des options selon le rôle
    List<Map<String, dynamic>> menuItems = [];
    
    if (role == Role.students) {
      menuItems.addAll(studentItems);
    } else {
      menuItems.addAll(parentItems);
    }
    
    menuItems.add(logoutItem);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item['color'],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item['icon'],
                color: item['iconColor'],
                size: 20,
              ),
            ),
            title: Text(
              item['title'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
            onTap: item['onTap'],
          ),
        );
      },
    );
  }

  Widget _buildStudentCalendar() {
    return SfCalendar(
      view: CalendarView.week,
      dataSource: _getCalendarDataSource(),
      headerStyle: const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      todayHighlightColor: const Color(0xFF8687E7),
      timeSlotViewSettings: const TimeSlotViewSettings(
        startHour: 8,
        endHour: 18,
        nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday],
      ),
      firstDayOfWeek: 1,
    );
  }

  MeetingDataSource _getCalendarDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    
    meetings.add(
      Meeting(
        'Mathématiques',
        DateTime(today.year, today.month, today.day + 1, 9, 0, 0),
        DateTime(today.year, today.month, today.day + 1, 11, 0, 0),
        const Color(0xFF8687E7),
        false,
        'Salle 204 - M. Dupont',
      ),
    );
    
    meetings.add(
      Meeting(
        'Histoire',
        DateTime(today.year, today.month, today.day + 1, 13, 0, 0),
        DateTime(today.year, today.month, today.day + 1, 15, 0, 0),
        const Color(0xFF26A69A),
        false,
        'Salle 112 - Mme Martin',
      ),
    );
    
    meetings.add(
      Meeting(
        'Sciences',
        DateTime(today.year, today.month, today.day + 2, 10, 0, 0),
        DateTime(today.year, today.month, today.day + 2, 12, 0, 0),
        const Color(0xFFFFB74D),
        false,
        'Labo 3 - M. Leroy',
      ),
    );
    
    return MeetingDataSource(meetings);
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  @override
  String getNotes(int index) {
    return _getMeetingData(index).description;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }
    return meetingData;
  }
}

class Meeting {
  Meeting(
    this.eventName,
    this.from,
    this.to,
    this.background,
    this.isAllDay,
    this.description,
  );

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String description;
}