import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

enum Role { parents, students }

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> user;
  final Role role;

  const ProfilePage({
    Key? key, 
    required this.user, 
    this.role = Role.students
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 12),
            _buildSectionTitle('Paramètres du compte'),
            _buildSettingsMenuItems(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Avatar centré en haut
          Container(
            width: 90, // Agrandi par rapport à l'original
            height: 90, // Agrandi par rapport à l'original
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAFF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 45, // Agrandi par rapport à l'original
                color: Color(0xFF8687E7),
              ),
            ),
          ),
          const SizedBox(height: 5),
          // Informations utilisateur en dessous
          Text(
            user['name'],
            style: const TextStyle(
              fontSize: 22, // Agrandi par rapport à l'original
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16, // Agrandi par rapport à l'original
                color: Colors.grey,
              ),
              const SizedBox(width: 2),
              Text(
                user['location'] ?? 'Emplacement non défini',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16, // Agrandi par rapport à l'original
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
                  size: 16, // Agrandi par rapport à l'original
                  color: role == Role.students 
                      ? const Color(0xFF26A69A) 
                      : const Color(0xFF9C27B0),
                ),
                const SizedBox(width: 4),
                Text(
                  role == Role.students ? 'Élève' : 'Parent',
                  style: TextStyle(
                    fontSize: 16, // Agrandi par rapport à l'original
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

  Widget _buildSettingsMenuItems(BuildContext context) {
    // Options de base communes à tous les rôles
    final List<Map<String, dynamic>> baseSettingsItems = [
      {
        'icon': Icons.person_outline,
        'title': 'Paramètres du profil',
        'color': const Color(0xFFE8EAFF),
        'iconColor': const Color(0xFF8687E7),
        'onTap': () {}
      },
    ];
    
    // Options spécifiques aux élèves
    final List<Map<String, dynamic>> studentItems = [
      {
        'icon': Icons.calendar_today,
        'title': 'Emploi du temps',
        'color': const Color(0xFFE0F7EF),
        'iconColor': const Color(0xFF26A69A),
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
      {
        'icon': Icons.school_outlined,
        'title': 'Cours',
        'color': const Color(0xFFFFEFEB),
        'iconColor': const Color(0xFFFF8A65),
        'onTap': () {}
      },
      {
        'icon': Icons.assignment_outlined,
        'title': 'Devoirs',
        'color': const Color(0xFFEAE0FF),
        'iconColor': const Color(0xFF9575CD),
        'onTap': () {}
      },
      {
        'icon': Icons.grade_outlined,
        'title': 'Notes',
        'color': const Color(0xFFFFF4DE),
        'iconColor': const Color(0xFFFFB74D),
        'onTap': () {}
      },
    ];
    
    // Options spécifiques aux parents
    final List<Map<String, dynamic>> parentItems = [
      {
        'icon': Icons.calendar_today,
        'title': 'Emploi du temps des enfants',
        'color': const Color(0xFFE0F7EF),
        'iconColor': const Color(0xFF26A69A),
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
      {
        'icon': Icons.family_restroom,
        'title': 'Mes enfants',
        'color': const Color(0xFFEEDCFF),
        'iconColor': const Color(0xFF9C27B0),
        'onTap': () {}
      },
      {
        'icon': Icons.message_outlined,
        'title': 'Messages aux enseignants',
        'color': const Color(0xFFE0F2FF),
        'iconColor': const Color(0xFF2196F3),
        'onTap': () {}
      },
      {
        'icon': Icons.trending_up,
        'title': 'Suivi des résultats',
        'color': const Color(0xFFFFF4DE),
        'iconColor': const Color(0xFFFFB74D),
        'onTap': () {}
      },
    ];
    
    // Option de déconnexion commune
    final Map<String, dynamic> logoutItem = {
      'icon': Icons.logout,
      'title': 'Déconnexion',
      'color': const Color(0xFFFFE0E0),
      'iconColor': const Color(0xFFEF5350),
      'onTap': () async {
        // Logique de déconnexion
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Retourner à l'écran de connexion
        Navigator.of(context).pushReplacementNamed('/login');
      }
    };
    
    // Combiner les options selon le rôle
    List<Map<String, dynamic>> settingsItems = [...baseSettingsItems];
    
    if (role == Role.students) {
      settingsItems.addAll(studentItems);
    } else {
      settingsItems.addAll(parentItems);
    }
    
    // Ajouter l'option de déconnexion à la fin
    settingsItems.add(logoutItem);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: settingsItems.length,
      itemBuilder: (context, index) {
        final item = settingsItems[index];
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
    
    // Les mêmes événements que dans le code original
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

// Classe pour les meetings du calendrier (inchangée)
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