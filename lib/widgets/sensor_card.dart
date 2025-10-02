import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isCritical;
  final Gradient? gradient;

  const SensorCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.isCritical = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // Largeur fixe pour toutes les cartes
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: gradient ?? LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white),
                  ),
                  if (isCritical)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ALERTE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              LinearProgressIndicator(
                value: _getProgressValue(),
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCritical ? Colors.red[100]! : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getProgressValue() {
    if (title.contains('TEMP')) {
      return (double.tryParse(value.replaceAll('°C', '')) ?? 0) / 50;
    } else if (title.contains('HUMID')) {
      return (double.tryParse(value.replaceAll('%', '')) ?? 0) / 100;
    } else if (title.contains('GAZ')) {
      return (double.tryParse(value.replaceAll(' ppm', '')) ?? 0) / 500;
    }
    return isCritical ? 1.0 : 0.3;
  }
}