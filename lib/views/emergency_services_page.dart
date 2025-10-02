import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Pour passer des appels
import 'package:geolocator/geolocator.dart'; // Pour la géolocalisation
import 'package:permission_handler/permission_handler.dart'; // Pour les permissions
import 'package:animate_do/animate_do.dart'; // Pour les animations
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Pour des icônes modernes

class EmergencyServicesPage extends StatefulWidget {
  const EmergencyServicesPage({super.key});

  @override
  EmergencyServicesPageState createState() => EmergencyServicesPageState();
}

class EmergencyServicesPageState extends State<EmergencyServicesPage> {
  // Fonction pour passer un appel
  Future<void> _callEmergencyService(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Impossible de passer l\'appel : $phoneNumber';
    }
  }

  // Fonction pour obtenir la position actuelle
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Les services de localisation sont désactivés.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Les permissions de localisation sont refusées.';
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  // Fonction pour envoyer un message prédéfini
  Future<void> _sendEmergencyMessage(String phoneNumber) async {
    try {
      // Vérifiez et demandez la permission d'envoyer des SMS
      if (await Permission.sms.request().isGranted) {
        final Position position = await _getCurrentLocation();
        final String message =
            'URGENCE ! Je suis à cette position : https://maps.google.com/?q=${position.latitude},${position.longitude}';

        final Uri uri = Uri.parse('sms:$phoneNumber?body=$message');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          throw 'Aucune application trouvée pour envoyer des SMS.';
        }
      } else {
        throw 'Permission d\'envoyer des SMS refusée.';
      }
    } catch (e) {
      throw 'Erreur lors de l\'envoi du message : $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Couleur dominante de l'interface (par exemple, rouge pour les pompiers)
    final Color appBarColor = Colors.red; // Vous pouvez changer cette couleur selon vos préférences

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Services d\'Urgence',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Texte blanc pour un meilleur contraste
          ),
        ),
        backgroundColor: appBarColor, // Couleur dominante de l'interface
        centerTitle: true,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildEmergencyCard(
              context,
              title: 'Appeler les Pompiers',
              icon: FontAwesomeIcons.fireExtinguisher,
              color: Colors.red,
              onTap: () => _callEmergencyService('198'),
            ),
            _buildEmergencyCard(
              context,
              title: 'Appeler la Police',
              icon: FontAwesomeIcons.shieldHalved,
              color: Colors.blue,
              onTap: () => _callEmergencyService('197'),
            ),
            _buildEmergencyCard(
              context,
              title: 'Appeler une Ambulance',
              icon: FontAwesomeIcons.truckMedical,
              color: Colors.green,
              onTap: () => _callEmergencyService('190'),
            ),
            _buildEmergencyCard(
              context,
              title: 'Envoyer un Message d\'Urgence',
              icon: FontAwesomeIcons.commentDots,
              color: Colors.orange,
              onTap: () async {
                try {
                  await _sendEmergencyMessage('198');
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur : $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour créer une carte d'urgence
  Widget _buildEmergencyCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: color,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 40),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}