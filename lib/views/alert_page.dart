import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:badges/badges.dart' as badges; // Importez le package badges
import 'package:provider/provider.dart'; // Importez Provider
import '../models/alert.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart'; // Importez NotificationService
import '../providers/unread_alerts_provider.dart'; // Importez le Provider

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  final SupabaseService supabaseService = SupabaseService();
  final NotificationService notificationService = NotificationService(); // Ajoutez NotificationService
  List<Alert> alerts = [];
  bool isLoading = true;
  bool showCriticalOnly = false;
  String sortBy = 'Date';
  String searchQuery = '';
  bool _isNotificationsEnabled = true; // Variable pour stocker la préférence de notifications
  StreamSubscription<bool>? _notificationSubscription; // Pour écouter les changements

  @override
  void initState() {
    super.initState();
    fetchAlerts();
    _loadNotificationPreference(); // Chargez la préférence de l'utilisateur

    // Écouter les changements de l'état des notifications
    _notificationSubscription = notificationService.notificationStream.listen((isEnabled) {
      setState(() {
        _isNotificationsEnabled = isEnabled;
      });
      fetchAlerts();
    });
  }

  @override
  void dispose() {
    // Annuler l'abonnement au Stream pour éviter les fuites de mémoire
    _notificationSubscription?.cancel();
    super.dispose();
  }

  // Charger la préférence de notifications
  Future<void> _loadNotificationPreference() async {
    final isEnabled = await notificationService.getNotificationPreference();
    setState(() {
      _isNotificationsEnabled = isEnabled;
    });
  }

  Future<void> fetchAlerts() async {
    try {
      final data = await supabaseService.fetchAlerts();
      setState(() {
        if (_isNotificationsEnabled) {
          alerts = data.map((alert) => Alert.fromMap(alert)).toList();
        } else {
          alerts = [];
        }
        isLoading = false;
      });

      // Mettre à jour le nombre d'alertes non lues
      final unreadCount = alerts.where((alert) => !alert.isRead).length;
      Provider.of<UnreadAlertsProvider>(context, listen: false).updateUnreadAlertsCount(unreadCount);
    } catch (e) {
      debugPrint('Erreur lors de la récupération des alertes : $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> markAlertAsRead(int alertId) async {
    try {
      await supabaseService.markAlertAsRead(alertId);
      setState(() {
        final alert = alerts.firstWhere((a) => a.id == alertId);
        alert.isRead = true;
      });

      // Mettre à jour le nombre d'alertes non lues après avoir marqué une alerte comme lue
      final unreadCount = alerts.where((alert) => !alert.isRead).length;
      Provider.of<UnreadAlertsProvider>(context, listen: false).updateUnreadAlertsCount(unreadCount);
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de l\'alerte : $e');
    }
  }

  List<Alert> getFilteredAlerts() {
    return alerts.where((alert) {
      final titleMatch = alert.title.toLowerCase().contains(searchQuery.toLowerCase());
      final descriptionMatch = alert.description.toLowerCase().contains(searchQuery.toLowerCase());

      if (showCriticalOnly) {
        return (titleMatch || descriptionMatch) && alert.isCritical;
      } else {
        return titleMatch || descriptionMatch;
      }
    }).toList();
  }

  List<Alert> getSortedAlerts(List<Alert> filteredAlerts) {
    return filteredAlerts..sort((a, b) {
      if (sortBy == 'Date') {
        return b.timestamp.compareTo(a.timestamp);
      } else if (sortBy == 'Priorité') {
        return b.isCritical ? 1 : -1;
      } else {
        return a.isRead ? 1 : -1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final unreadCount = alerts.where((alert) => !alert.isRead).length; // Nombre d'alertes non lues

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredAlerts = getFilteredAlerts();
    final sortedAlerts = getSortedAlerts(filteredAlerts);

    return Scaffold(
      backgroundColor: Colors.transparent, // Arrière-plan transparent
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Alertes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Texte blanc pour un meilleur contraste
              ),
            ),
            const SizedBox(width: 10), // Espacement entre le titre et le badge
            // Badge pour afficher le nombre d'alertes non lues
            badges.Badge(
              badgeContent: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              showBadge: unreadCount > 0, // Afficher le badge uniquement s'il y a des alertes non lues
              child: const Icon(Icons.notifications, color: Colors.white), // Icône de notification
            ),
          ],
        ),
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0, // Supprime l'ombre de l'AppBar
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Colors.deepOrange.shade900, Colors.black] // Dégradé sombre (orange foncé à noir)
                  : [Colors.orange.shade400, Colors.yellow.shade200], // Dégradé clair (orange à jaune clair)
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              showCriticalOnly ? Icons.warning : Icons.filter_list,
              color: Colors.white, // Icône blanche pour un meilleur contraste
            ),
            onPressed: () {
              setState(() {
                showCriticalOnly = !showCriticalOnly;
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Date',
                child: Text('Trier par date'),
              ),
              const PopupMenuItem(
                value: 'Priorité',
                child: Text('Trier par priorité'),
              ),
              const PopupMenuItem(
                value: 'Statut',
                child: Text('Trier par statut'),
              ),
            ],
            icon: Icon(Icons.sort, color: Colors.white), // Icône blanche pour un meilleur contraste
          ),
        ],
      ),
      body: GradientBackground(
        child: Column(
          children: [
            _buildStatistics(isDarkMode),
            Expanded(
              child: _isNotificationsEnabled
                  ? ListView.builder(
                      itemCount: sortedAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = sortedAlerts[index];
                        return _buildAlertCard(alert, isDarkMode);
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Centre verticalement
                        children: [
                          Icon(
                            Icons.notifications_off_rounded, // Icône pour illustrer le message
                            size: 60,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(height: 16), // Espacement
                          Text(
                            'Notifications désactivées',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aucune alerte ne sera affichée.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
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

  Widget _buildStatistics(bool isDarkMode) {
    final criticalCount = alerts.where((alert) => alert.isCritical).length;
    final unreadCount = alerts.where((alert) => !alert.isRead).length;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatistic('Critiques', criticalCount, Colors.red, isDarkMode),
              _buildStatistic('Non lues', unreadCount, Colors.blue, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistic(String label, int count, Color color, bool isDarkMode) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(Alert alert, bool isDarkMode) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        leading: Lottie.asset(
          alert.isCritical ? 'assets/animations/warning.json' : 'assets/animations/notification.json',
          width: 50,
          height: 50,
        ),
        title: Text(
          alert.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black,
            decoration: alert.isRead ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert.description,
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              '${alert.timestamp.hour}:${alert.timestamp.minute}',
              style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white54 : Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            // Afficher l'état des notifications
            Text(
              _isNotificationsEnabled ? 'Notifications activées' : 'Notifications désactivées',
              style: TextStyle(
                fontSize: 12,
                color: _isNotificationsEnabled ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            alert.isRead ? Icons.check_circle : Icons.check_circle_outline,
            color: alert.isRead ? Colors.green : Colors.grey,
          ),
          onPressed: () {
            markAlertAsRead(alert.id);
          },
        ),
      ),
    );
  }
}

// Widget pour l'arrière-plan dégradé dynamique
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.deepOrange.shade900, Colors.black] // Dégradé sombre (orange foncé à noir)
              : [Colors.orange.shade400, Colors.yellow.shade200], // Dégradé clair (orange à jaune clair)
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}