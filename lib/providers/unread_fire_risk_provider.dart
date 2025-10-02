import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnreadFireRiskProvider extends ChangeNotifier {
  int _unreadFireRiskCount = 0;
  DateTime? _lastCheckTime;
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _lastCheckTimeKey = 'last_fire_risk_check_time';

  UnreadFireRiskProvider() {
    _initLastCheckTime();
    _setupRealtimeSubscription();
  }

  int get unreadFireRiskCount => _unreadFireRiskCount;

  // Initialise le timestamp de la dernière vérification depuis les SharedPreferences
  Future<void> _initLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTime = prefs.getString(_lastCheckTimeKey);
    if (storedTime != null) {
      _lastCheckTime = DateTime.parse(storedTime);
    } else {
      _lastCheckTime = DateTime.now();
      await _saveLastCheckTime();
    }
    _checkForNewFireRisks();
  }

  // Sauvegarde le timestamp actuel dans les SharedPreferences
  Future<void> _saveLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCheckTimeKey, DateTime.now().toIso8601String());
    _lastCheckTime = DateTime.now();
  }

  // Configure l'abonnement en temps réel pour les nouvelles insertions
  void _setupRealtimeSubscription() {
    _supabase
        .channel('fire_risk_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'fire_risk_analysis',
          callback: (payload) {
            // Une nouvelle analyse de risque d'incendie a été insérée
            incrementUnreadFireRiskCount();
          },
        )
        .subscribe();
  }

  // Vérifie s'il y a de nouvelles analyses de risque depuis la dernière vérification
  Future<void> _checkForNewFireRisks() async {
    if (_lastCheckTime == null) return;

    try {
      final response = await _supabase
          .from('fire_risk_analysis')
          .select('id')
          .gt('analysis_time', _lastCheckTime!.toIso8601String())
          .count();

      if (response is PostgrestResponse) {
        final count = response.count ?? 0;
        if (count > 0) {
          _unreadFireRiskCount = count;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification des nouveaux risques d\'incendie: $e');
    }
  }

  void setUnreadFireRiskCount(int count) {
    _unreadFireRiskCount = count;
    notifyListeners();
  }

  void incrementUnreadFireRiskCount() {
    _unreadFireRiskCount++;
    notifyListeners();
  }

  Future<void> resetUnreadFireRiskCount() async {
    if (_unreadFireRiskCount > 0) {
      _unreadFireRiskCount = 0;
      await _saveLastCheckTime();
      notifyListeners();
    }
  }

  // Méthode de nettoyage pour fermer la souscription si nécessaire
  void dispose() {
    _supabase.removeChannel(_supabase.getChannels()[0]);
    super.dispose();
  }
}