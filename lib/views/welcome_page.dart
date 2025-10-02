import 'package:flutter/material.dart';
import 'package:smart_fire_alarm/main.dart'; // Importez le fichier où NavigationWrapper est défini

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Configuration de l'animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Répéter l'animation en boucle

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Délai de 10 secondes avant la navigation
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const NavigationWrapper(
            enableNotifications: true,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Nettoyer l'animation
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.indigo.shade900, Colors.black]
                : [Colors.blue.shade400, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône textile animée
                ScaleTransition(
                  scale: _animation,
                  child: Image.asset(
                    'assets/images/cotton_icon.png.png', // Chemin de l'image
                    width: 200, // Augmentez la largeur
                    height: 200, // Augmentez la hauteur
                    color: isDarkMode ? Colors.white : Colors.blue.shade900, // Couleur dynamique
                  ),
                ),
                const SizedBox(height: 20),
                // Titre principal
                AnimatedDefaultTextStyle(
                  duration: const Duration(seconds: 1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.blue.shade900,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Text('SITEX'),
                ),
                const SizedBox(height: 10),
                // Sous-titre
                AnimatedDefaultTextStyle(
                  duration: const Duration(seconds: 1),
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode ? Colors.white.withOpacity(0.8) : Colors.blue.shade900.withOpacity(0.8),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: const Text('Innovation et qualité dans le textile'),
                ),
                const SizedBox(height: 40),
                // Bouton "Commencer"
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [Colors.purple.shade400, Colors.indigo.shade600]
                          : [Colors.blue.shade400, Colors.blue.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const NavigationWrapper(
                            enableNotifications: true,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Commencer',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}