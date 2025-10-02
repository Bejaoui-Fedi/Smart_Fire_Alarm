import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SensorChart extends StatelessWidget {
  final String title; // Titre du graphique
  final List<double> data; // Données historiques pour le graphique
  final Color color; // Couleur de la ligne du graphique

  const SensorChart({
    super.key,
    required this.title,
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Ombre de la carte
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Bords arrondis
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre du graphique
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8), // Espacement entre le titre et le graphique
            // Graphique en temps réel
            SizedBox(
              height: 200, // Hauteur du graphique
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false), // Masquer la grille
                  titlesData: FlTitlesData(show: false), // Masquer les titres
                  borderData: FlBorderData(show: false), // Masquer les bordures
                  lineBarsData: [
                    LineChartBarData(
                      spots: data
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                          .toList(), // Convertir les données en points
                      isCurved: true, // Courber la ligne
                      color: color, // Couleur de la ligne
                      dotData: FlDotData(show: false), // Masquer les points
                      belowBarData: BarAreaData(show: false), // Masquer la zone sous la ligne
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}