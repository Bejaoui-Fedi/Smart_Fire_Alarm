import 'package:supabase_flutter/supabase_flutter.dart';
import 'sms_service.dart';

class AlertListener {
  final SupabaseClient supabase;
  RealtimeChannel? _channel;

  AlertListener(this.supabase);

  void startListening() {
    _channel = supabase.channel('alerts')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'alerts',
        callback: (payload) {
          final alert = payload.newRecord;
          SMSService.sendAutoSMS(
            '+21693152648', // Ton numéro fixe
            '🚨 Alerte: ${alert['title']}\n${alert['description']}',
          );
        },
      )
      .subscribe();
  }

  void stopListening() {
    _channel?.unsubscribe();
  }
}