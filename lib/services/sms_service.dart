import 'package:flutter/services.dart';

class SMSService {
  static const _channel = MethodChannel('com.example.smart_fire_alarm/sms');

  static Future<void> sendAutoSMS(String phoneNumber, String message) async {
    try {
      await _channel.invokeMethod('sendSMS', {
        'phone': phoneNumber, // Numéro dynamique
        'message': message,
      });
      print('SMS envoyé avec succès à $phoneNumber');
    } on PlatformException catch (e) {
      print("Échec d'envoi SMS: ${e.message}");
    }
  }
}