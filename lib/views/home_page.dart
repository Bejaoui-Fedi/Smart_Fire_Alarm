import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import 'data_cards_page.dart';
import 'charts_page.dart';
import 'emergency_services_page.dart';
import '../providers/unread_alerts_provider.dart';
import '../providers/unread_fire_risk_provider.dart'; // Import du nouveau provider
import 'alert_page.dart';
import 'fire_risk_page.dart';
import 'unified_control_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _isAlertButtonPressed = false;
  bool _isFireRiskButtonPressed = false;
  bool _isControlButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDarkMode
        ? [Colors.indigo.shade900, Colors.black]
        : [Colors.blue.shade400, Colors.white];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Accueil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            // Bouton de Contrôle Unifié
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTapDown: (_) => setState(() => _isControlButtonPressed = true),
                onTapUp: (_) => setState(() => _isControlButtonPressed = false),
                onTapCancel: () => setState(() => _isControlButtonPressed = false),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UnifiedControlPage()),
                  ).then((_) {
                    setState(() => _isControlButtonPressed = false);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..scale(_isControlButtonPressed ? 0.9 : 1.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.purple.shade300,
                      ),
                    ),
                    child: const Icon(
                      Icons.dashboard_customize,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            // Bouton Risque d'Incendie
            Consumer<UnreadFireRiskProvider>(
              builder: (context, fireRiskProvider, child) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -10, end: -10),
                    showBadge: fireRiskProvider.unreadFireRiskCount > 0,
                    badgeContent: Text(
                      fireRiskProvider.unreadFireRiskCount > 9
                          ? '9+'
                          : fireRiskProvider.unreadFireRiskCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: Colors.orange,
                      padding: EdgeInsets.all(6),
                      borderSide: BorderSide(color: Colors.white, width: 2),
                      elevation: 4,
                    ),
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _isFireRiskButtonPressed = true),
                      onTapUp: (_) => setState(() => _isFireRiskButtonPressed = false),
                      onTapCancel: () => setState(() => _isFireRiskButtonPressed = false),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FireRiskAnalysisScreen()),
                        ).then((_) {
                          fireRiskProvider.resetUnreadFireRiskCount();
                          setState(() => _isFireRiskButtonPressed = false);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()
                          ..scale(_isFireRiskButtonPressed ? 0.9 : 1.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: fireRiskProvider.unreadFireRiskCount > 0
                                ? Colors.orange.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                            border: Border.all(
                              color: fireRiskProvider.unreadFireRiskCount > 0
                                  ? Colors.orange.shade300
                                  : Colors.orange.shade300,
                            ),
                          ),
                          child: const Icon(
                            Icons.local_fire_department_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Bouton Alertes
            Consumer<UnreadAlertsProvider>(
              builder: (context, alertsProvider, child) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -10, end: -10),
                    showBadge: alertsProvider.unreadAlertsCount > 0,
                    badgeContent: Text(
                      alertsProvider.unreadAlertsCount > 9
                          ? '9+'
                          : alertsProvider.unreadAlertsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: Colors.red,
                      padding: EdgeInsets.all(6),
                      borderSide: BorderSide(color: Colors.white, width: 2),
                      elevation: 4,
                    ),
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _isAlertButtonPressed = true),
                      onTapUp: (_) => setState(() => _isAlertButtonPressed = false),
                      onTapCancel: () => setState(() => _isAlertButtonPressed = false),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AlertPage()),
                        ).then((_) {
                          alertsProvider.resetUnreadAlertsCount();
                          setState(() => _isAlertButtonPressed = false);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()
                          ..scale(_isAlertButtonPressed ? 0.9 : 1.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: alertsProvider.unreadAlertsCount > 0
                                ? Colors.red.withOpacity(0.2)
                                : Colors.white.withOpacity(0.2),
                            border: Border.all(
                              color: alertsProvider.unreadAlertsCount > 0
                                  ? Colors.red.shade300
                                  : Colors.white.withOpacity(0.4),
                            ),
                          ),
                          child: Icon(
                            Icons.notifications_active_outlined,
                            color: alertsProvider.unreadAlertsCount > 0
                                ? Colors.red.shade300
                                : Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tableau de bord',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  _buildClickableSection(
                    context,
                    title: 'Cartes des Données',
                    lottieAsset: 'assets/animations/data.json',
                    color: isDarkMode ? Colors.blueAccent : Colors.blue.shade400,
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const DataCardsPage()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildClickableSection(
                    context,
                    title: 'Graphiques Live',
                    lottieAsset: 'assets/animations/charts.json',
                    color: isDarkMode ? Colors.greenAccent : Colors.green.shade400,
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const ChartsPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Services d\'urgence',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildClickableSection(
                context,
                title: 'Services d\'Urgence',
                lottieAsset: 'assets/animations/emergency.json',
                color: isDarkMode ? Colors.redAccent : Colors.red.shade400,
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const EmergencyServicesPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClickableSection(
    BuildContext context, {
    required String title,
    required String lottieAsset,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Lottie.asset(
                lottieAsset,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}