import 'package:flutter/material.dart';
import 'package:mon_elearning/pages/welcome_logo.dart'; // ← importe WelcomeLogoPage

class WelcomePage extends StatelessWidget {
  final int seconds;

  const WelcomePage({super.key, this.seconds = 3});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: seconds), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeLogoPage()),
      );
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/welcome2.jpeg',
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
