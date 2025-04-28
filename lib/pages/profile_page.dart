import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:math' as math;

enum Role { parents, students }

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.logout, color: Colors.white),
      //       onPressed: () async {
      //         // Logique de déconnexion
      //         final prefs = await SharedPreferences.getInstance();
      //         await prefs.clear();
              
      //         // Retourner à l'écran de connexion
      //         Navigator.of(context).pushReplacementNamed('/login');
      //       },
      //     ),
      //   ],
      // ),
      body: Column(
        children: [
          // Section du haut avec vague
          _buildHeaderSection(context),
          
          // Section principale avec les cartes
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _buildQuickActions(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Stack(
      children: [
        // Fond ondulé
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 0, 74, 173),  // Bleu foncé
                  Color.fromARGB(255, 41, 121, 255),  // Bleu moyen
                  Color.fromARGB(255, 100, 181, 246),  // Bleu clair
                ],
              ),
            ),
          ),
        ),
        
        // Contenu de l'en-tête
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Bonjour,',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () async {
                      // Logique de déconnexion
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      
                      // Retourner à l'écran de connexion
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 5),
                          
                          Text(
                            'Sortie',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                user['name'],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // const SizedBox(height: 25),
              // const Text(
              //   'Commencer un nouveau trajet',
              //   style: TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.w500,
              //     color: Colors.white,
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        'label': 'Cours',
        'icon': Icons.school,
        'color': const Color.fromARGB(255, 226, 81, 45), // Rouge
        'bgColor': const Color.fromARGB(255, 226, 81, 45).withOpacity(0.1),
        'onTap': () {}
      },
      {
        'label': 'Emploi du temps',
        'icon': Icons.calendar_today,
        'color': const Color.fromARGB(255, 33, 150, 83), // Vert
        'bgColor': const Color.fromARGB(255, 33, 150, 83).withOpacity(0.1),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Emploi du temps'),
                  backgroundColor: const Color.fromARGB(255, 0, 74, 173),
                ),
                body: _buildStudentCalendar(),
              ),
            ),
          );
        }
      },
      {
        'label': 'Devoirs',
        'icon': Icons.assignment,
        'color': const Color.fromARGB(255, 156, 39, 176), // Violet
        'bgColor': const Color.fromARGB(255, 156, 39, 176).withOpacity(0.1),
        'onTap': () {}
      },
      {
        'label': 'Notes',
        'icon': Icons.grade,
        'color': const Color.fromARGB(255, 255, 152, 0), // Orange
        'bgColor': const Color.fromARGB(255, 255, 152, 0).withOpacity(0.1),
        'onTap': () {}
      },
      {
        'label': 'Statistiques',
        'icon': Icons.trending_up,
        'color': const Color.fromARGB(255, 0, 74, 173), // Bleu foncé
        'bgColor': const Color.fromARGB(255, 0, 74, 173).withOpacity(0.1),
        'onTap': () {}
      },
      {
        'label': 'Documents',
        'icon': Icons.folder,
        'color': const Color.fromARGB(255, 121, 85, 72), // Marron
        'bgColor': const Color.fromARGB(255, 121, 85, 72).withOpacity(0.1),
        'onTap': () {}
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: TweenSequence<double>([
            TweenSequenceItem(
              tween: Tween<double>(begin: 0, end: 1),
              weight: 1,
            ),
          ]).animate(
            CurvedAnimation(
              parent: ModalRoute.of(context)?.animation ?? AnimationController(vsync: NavigatorState(), duration: const Duration(milliseconds: 500)),
              curve: Interval(0.1 * index, 0.1 * index + 0.5, curve: Curves.easeOut),
            ),
          ),
          child: _buildActionButton(
            actions[index]['label'],
            actions[index]['icon'],
            actions[index]['color'],
            actions[index]['bgColor'],
            actions[index]['onTap'],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    Color bgColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      splashColor: color.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              builder: (context, double value, child) {
                return Transform.rotate(
                  angle: math.pi * 2 * value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
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
      todayHighlightColor: const Color.fromARGB(255, 0, 74, 173),
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
        const Color.fromARGB(255, 0, 74, 173),
        false,
        'Salle 204 - M. Dupont',
      ),
    );
    
    meetings.add(
      Meeting(
        'Histoire',
        DateTime(today.year, today.month, today.day + 1, 13, 0, 0),
        DateTime(today.year, today.month, today.day + 1, 15, 0, 0),
        const Color.fromARGB(255, 41, 121, 255),
        false,
        'Salle 112 - Mme Martin',
      ),
    );
    
    meetings.add(
      Meeting(
        'Sciences',
        DateTime(today.year, today.month, today.day + 2, 10, 0, 0),
        DateTime(today.year, today.month, today.day + 2, 12, 0, 0),
        const Color.fromARGB(255, 100, 181, 246),
        false,
        'Labo 3 - M. Leroy',
      ),
    );
    
    return MeetingDataSource(meetings);
  }
}

// Classe pour créer l'effet de vague
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    
    final firstControlPoint = Offset(size.width / 4, size.height);
    final firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx, 
      firstControlPoint.dy, 
      firstEndPoint.dx, 
      firstEndPoint.dy
    );
    
    final secondControlPoint = Offset(size.width * 0.75, size.height - 60);
    final secondEndPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
      secondControlPoint.dx, 
      secondControlPoint.dy, 
      secondEndPoint.dx, 
      secondEndPoint.dy
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
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