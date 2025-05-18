import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EnfantDetails extends StatefulWidget {
  final String fullName;
  final int studentId;
  final String levelName;
  final String className;

  const EnfantDetails({
    Key? key,
    required this.fullName,
    required this.studentId,
    required this.levelName,
    required this.className,
  }) : super(key: key);

  @override
  _EnfantDetailsState createState() => _EnfantDetailsState();
}

class _EnfantDetailsState extends State<EnfantDetails> {
  // Couleurs principales
  final Color _primaryColor = const Color(0xFF6C63FF);
  final Color _secondaryColor = const Color(0xFFFF6584);

  // Données d'activité (hardcoded for now, should be fetched via API in production)
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.fullName.isNotEmpty ? widget.fullName : 'Détails de l\'enfant'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildHeader(),
            // const SizedBox(height: 24),
            _buildProgressSection(),
            const SizedBox(height: 24),
            _buildActivitySection(),
          ],
        ),
      ),
    );
  }

  // Widget _buildHeader() {
  //   // Déterminer la couleur et l'icône selon le niveau
  //   Map<String, Map<String, dynamic>> levelStyles = {
  //     'Avancé': {
  //       'color': Colors.green,
  //       'icon': Icons.emoji_events,
  //     },
  //     'Intermédiaire': {
  //       'color': Colors.orange,
  //       'icon': Icons.star,
  //     },
  //     'Débutant': {
  //       'color': Colors.blue,
  //       'icon': Icons.auto_stories,
  //     },
  //   };

  //   final levelStyle = levelStyles[widget.levelName] ?? {
  //     'color': Colors.grey,
  //     'icon': Icons.school,
  //   };

  //   // Initiales pour l'avatar
  //   final initials = widget.fullName.isNotEmpty
  //       ? widget.fullName
  //           .split(' ')
  //           .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
  //           .join('')
  //       : '?';

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     child: Row(
  //       children: [
  //         Hero(
  //           tag: 'student_avatar_${widget.studentId}',
  //           child: Container(
  //             width: 60,
  //             height: 60,
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               shape: BoxShape.circle,
  //               border: Border.all(
  //                 color: levelStyle['color'],
  //                 width: 2,
  //               ),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: levelStyle['color'].withOpacity(0.2),
  //                   blurRadius: 8,
  //                   spreadRadius: 1,
  //                 ),
  //               ],
  //             ),
  //             child: Center(
  //               child: Text(
  //                 initials,
  //                 style: TextStyle(
  //                   color: levelStyle['color'],
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 22,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 16),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 widget.fullName.isNotEmpty ? widget.fullName : 'Nom non disponible',
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 18,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Row(
  //                 children: [
  //                   Icon(
  //                     Icons.class_,
  //                     size: 14,
  //                     color: Colors.grey[600],
  //                   ),
  //                   const SizedBox(width: 4),
  //                   Text(
  //                     widget.className,
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       color: Colors.grey[600],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 4),
  //               Row(
  //                 children: [
  //                   Icon(
  //                     Icons.insights,
  //                     size: 14,
  //                     color: levelStyle['color'],
  //                   ),
  //                   const SizedBox(width: 4),
  //                   Text(
  //                     widget.levelName,
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       color: levelStyle['color'],
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
                    'Activité de ${widget.fullName.split(' ').first}',
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
}