import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mon_elearning/pages/mdp_oublie.dart';
import 'package:mon_elearning/pages/mes_enfants.dart';
import 'package:mon_elearning/pages/navigation_bar.dart';
import 'package:mon_elearning/pages/welcome_logo.dart';
import 'package:mon_elearning/pages/onboarding_screen.dart';
import 'package:mon_elearning/pages/inscription.dart';
import 'package:mon_elearning/pages/connexion.dart' as cn; // Importation de la page SignInPage
import 'package:mon_elearning/pages/profile_page.dart'; // Importation de la page ProfilePage
import 'package:mon_elearning/utils/constantes.dart';
import 'package:mon_elearning/utils/firebase_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    final authToken = prefs.getString('authToken');

    if (authToken!= null) {
     final Map<String, dynamic> userInfo=  decodeJwtPayload(authToken);
      log(userInfo.toString());
      return HomeScreen(user: {
        'email': userInfo['email'],
        'id': userInfo['nameid'],
        'role': userInfo['role']
      });
    }
    return WelcomeLogoPage();
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
            home: snapshot.data ?? WelcomeLogoPage(),
            routes: {
              '/onboarding': (context) => OnboardingScreen(),
              '/login': (context) => cn.SignInPage(), // Page de connexion
              '/profile': (context) => ProfilePage(
                  user: ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>),
              '/signup': (context) => const SignUpPage(),
              '/mdp_oublie': (context) => const ForgotPasswordPage(),
              '/mes_enfants': (context) => const MesEnfantsPage(),
            },
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}



Map<String, dynamic> decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid JWT structure');
    }

    final payload = parts[1];
    
    // Base64 decoding (with padding fix)
    String normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));

    return json.decode(decoded) as Map<String, dynamic>;
  } catch (e) {
    print('Error decoding JWT: $e');
    return {};
  }
}
