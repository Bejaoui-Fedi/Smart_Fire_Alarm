import 'package:flutter/material.dart';

class UnreadAlertsProvider with ChangeNotifier {
  int _unreadAlertsCount = 0;

  int get unreadAlertsCount => _unreadAlertsCount;

  void updateUnreadAlertsCount(int count) {
    _unreadAlertsCount = count;
    notifyListeners(); // Notifie les écouteurs du changement
  }

  void resetUnreadAlertsCount() {
    _unreadAlertsCount = 0;
    notifyListeners(); // Notifie les écouteurs du changement
  }
}