import 'package:flutter/material.dart';
import 'dart:ui';
// Importe la page SignInPage
import 'package:mon_elearning/pages/connexion.dart'; // Remplace 'ton_application' par le chemin correct
// Importe la page SignUpPage
import 'package:mon_elearning/pages/inscription.dart'; // Remplace par le chemin correct de inscription.dart

// ... imports identiques

class PreSignPage extends StatelessWidget {
  const PreSignPage({super.key});

  @override
  Widget build(BuildContext context) {
    const EdgeInsets textPadding = EdgeInsets.only(top: 150.0, left: 40.0, right: 40.0);
    const EdgeInsets buttonsPadding = EdgeInsets.only(bottom: 200.0);
    const double buttonWidth = 220.0;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/welcome3.jpg',
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: textPadding,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.5,
                          ),
                          children: const [
                            TextSpan(text: 'Faites vos achats sur notre '),
                            TextSpan(
                              text: 'boutique',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 123, 0),
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' en toute simplicité'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: buttonsPadding,
                child: Column(
                  children: [
                    Container(
                      width: buttonWidth,
                      margin: const EdgeInsets.only(bottom: 15.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignInPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Connectez-vous',
                          style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 255, 123, 0)),
                        ),
                      ),
                    ),
                    Container(
                      width: buttonWidth,
                      margin: const EdgeInsets.only(bottom: 15.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 123, 0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
