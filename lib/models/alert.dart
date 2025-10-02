class Alert {
  final int id;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isCritical;
  bool isRead;

  Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isCritical,
    required this.isRead,
  });

  // Convertir un Map en objet Alert
  factory Alert.fromMap(Map<String, dynamic> map) {
    return Alert(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      timestamp: DateTime.parse(map['timestamp']),
      isCritical: map['is_critical'],
      isRead: map['is_read'],
    );
  }
}