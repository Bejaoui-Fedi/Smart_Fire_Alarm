class SensorData {
  final double temperature; // Température en °C
  final double humidity; // Humidité en %
  final double gas; // Concentration de gaz en ppm
  final bool flame; // Détection de flamme
  final bool smoke; // Détection de fumée

  const SensorData({
    required this.temperature,
    required this.humidity,
    required this.gas,
    required this.flame,
    required this.smoke,
  });
}