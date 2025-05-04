import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color.fromARGB(255, 255, 249, 245),
      ),
      body: ListView(
        children: [
          _buildNotificationItem(
            context,
            icon: Icons.assignment_turned_in,
            title: 'Nouveau cours disponible',
            subtitle: 'Le cours "Flutter Avancé" est maintenant disponible',
            time: 'Il y a 2 heures',
          ),
          _buildNotificationItem(
            context,
            icon: Icons.assignment_late,
            title: 'Devoir à rendre',
            subtitle: 'Le devoir de mathématiques est à rendre demain',
            time: 'Il y a 1 jour',
          ),
          _buildNotificationItem(
            context,
            icon: Icons.event_available,
            title: 'Nouvel événement',
            subtitle: 'Webinaire sur les nouvelles technologies demain à 14h',
            time: 'Il y a 2 jours',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 15, 64, 149),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: () {
          // Action lorsqu'on clique sur une notification
        },
      ),
    );
  }
}