import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // Importez dart:async pour utiliser StreamController

class NotificationService {
  static const String _key = 'enableNotifications';

  // StreamController pour notifier les changements
  final StreamController<bool> _notificationStreamController = StreamController<bool>.broadcast();

  // Stream pour écouter les changements
  Stream<bool> get notificationStream => _notificationStreamController.stream;

  Future<bool> getNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true; // Par défaut, les notifications sont activées
  }

  Future<void> setNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);

    // Notifier les écouteurs du changement
    _notificationStreamController.add(value);
  }

  // Fermer le StreamController lorsque vous n'en avez plus besoin
  void dispose() {
    _notificationStreamController.close();
  }
}