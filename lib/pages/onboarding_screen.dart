import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:ui'; // Nécessaire pour ImageFilter

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond unique
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // PageView pour les slides
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              OnboardingPage(
                slideImage: 'assets/images/slide1.png',
                title: 'Bienvenue',
                subtitle: 'Découvrez notre application avec facilité',
              ),
              OnboardingPage(
                slideImage: 'assets/images/slide2.png',
                title: 'Organisation',
                subtitle: 'Gérez vos tâches efficacement',
              ),
              OnboardingPage(
                slideImage: 'assets/images/slide4.png',
                title: 'Productivité',
                subtitle: 'Soyez plus productif chaque jour',
              ),
            ],
          ),
          
          // Indicateur + Bouton
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: WormEffect(
                    activeDotColor: Color.fromARGB(255, 0, 74, 173),
                    dotHeight: 12,
                    dotWidth: 12,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(60, 60),
                    backgroundColor: Color.fromARGB(255, 0, 74, 173),
                    shape: const CircleBorder(),
                  ),
                  onPressed: () {
                    if (onLastPage) {
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String slideImage;
  final String title;
  final String subtitle;

  const OnboardingPage({
    required this.slideImage,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image du slide - Taille augmentée (300 au lieu de 200)
            Image.asset(
              slideImage,
              height: 300, // Augmentation de la hauteur à 300
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            Text(
              title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}