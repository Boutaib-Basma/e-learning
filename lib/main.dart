import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mon_elearning/pages/navigation_bar.dart';
import 'package:mon_elearning/pages/welcome_page.dart';
import 'package:mon_elearning/pages/onboarding_screen.dart';
import 'package:mon_elearning/pages/inscription.dart';
import 'package:mon_elearning/pages/connexion.dart' as cn; // Importation de la page SignInPage
import 'package:mon_elearning/pages/profile_page.dart'; // Importation de la page ProfilePage
import 'package:mon_elearning/utils/constantes.dart';
import 'package:mon_elearning/utils/firebase_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessagingService.initialize();
 await getToken();
  runApp(const MyApp());
}
  Future<void> getToken()async{
    final token = await FirebaseMessaging.instance.getToken();
    log(token ?? 'No Token is available');
  }
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');
    final role = prefs.getString('userRole');
    final name = prefs.getString('userName');

    if (email != null && role != null && name != null) {
      return HomeScreen(user: {
        'email': email,
        'name': name,
        'role': role == 'Role.parents' ? Role.parents : Role.students
      });
    }
    return WelcomePage(seconds: 2);
  }
@override
  void initState() {
    super.initState();
    FirebaseMessagingService.configureForegroundHandler();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            theme: appTheme,
            title: 'Mon E-Learning',
            debugShowCheckedModeBanner: false,
            home: snapshot.data ?? WelcomePage(seconds: 2),
            routes: {
              '/onboarding': (context) => OnboardingScreen(),
              '/login': (context) => cn.SignInPage(), // Page de connexion
              '/profile': (context) => ProfilePage(
                  user: ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>),
              '/signup': (context) => const SignUpPage(),
            },
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
