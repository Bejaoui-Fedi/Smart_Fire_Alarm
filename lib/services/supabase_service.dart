import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Récupérer toutes les alertes
  Future<List<Map<String, dynamic>>> fetchAlerts() async {
    final response = await supabase
        .from('alerts')
        .select('*')
        .order('timestamp', ascending: false); // Trier par date (récent en premier)
    return response; // Pas besoin de cast
  }

  // Marquer une alerte comme lue
  Future<void> markAlertAsRead(int alertId) async {
    await supabase
        .from('alerts')
        .update({'is_read': true})
        .eq('id', alertId);
  }
}