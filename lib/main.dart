import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
 
import 'providers/theme_provider.dart';
import 'providers/unread_alerts_provider.dart';
import 'providers/chat_history_provider.dart';
import 'services/notification_service.dart';
import 'services/alert_listener.dart';
import 'views/home_page.dart';
import 'views/settings_page.dart';
import 'views/sign_in_page.dart';
import 'views/chatbot_screen.dart';
import 'providers/unread_fire_risk_provider.dart'; // Import du nouveau provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://kxtyvffgdgamkugzraaz.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt4dHl2ZmZnZGdhbWt1Z3pyYWF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA2ODc2OTEsImV4cCI6MjA1NjI2MzY5MX0.zc6rrJ4zIP3_bCemcPXDEEwt3gKvdTr_5AmmM0dDhqQ",
  );

  final notificationService = NotificationService();
  final enableNotifications = await notificationService.getNotificationPreference();
  final alertListener = AlertListener(Supabase.instance.client);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UnreadAlertsProvider()),
        ChangeNotifierProvider(create: (_) => UnreadFireRiskProvider()), // Ajout du provider pour les risques d'incendie

        ChangeNotifierProvider(
          create: (_) => ChatHistoryProvider()..loadChatHistory(),
        ),
        Provider<AlertListener>(create: (_) => alertListener),
      ],
      child: MyApp(enableNotifications: enableNotifications),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool enableNotifications;

  const MyApp({super.key, required this.enableNotifications});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final alertListener = Provider.of<AlertListener>(context, listen: false);

    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        alertListener.startListening();
      });
    }

    return MaterialApp(
      title: 'Smart Fire Alarm',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: user != null
          ? NavigationWrapper(enableNotifications: enableNotifications)
          : const SignInPage(),
    );
  }
}

class NavigationWrapper extends StatefulWidget {
  final bool enableNotifications;

  const NavigationWrapper({super.key, required this.enableNotifications});

  @override
  NavigationWrapperState createState() => NavigationWrapperState();
}

class NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  final List<Color> _activeColors = [
    Colors.blue,
    const Color.fromARGB(255, 244, 54, 190),
    Colors.deepPurple,
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const ChatbotScreen(),
      const SettingsPage(),
    ];
    _listenForUnreadAlerts();
  }

  void _listenForUnreadAlerts() {
    final supabase = Supabase.instance.client;
    supabase
        .from('alerts')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> alerts) {
      final unreadAlerts = alerts.where((alert) => alert['is_read'] == false).toList();
      final unreadAlertsProvider = Provider.of<UnreadAlertsProvider>(context, listen: false);
      unreadAlertsProvider.updateUnreadAlertsCount(unreadAlerts.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).toInt()),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _activeColors[_currentIndex],
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.home, 0),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.android, 1),
              label: 'Chatbot',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.settings, 2),
              label: 'Paramètres',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: _currentIndex == index
            ? LinearGradient(
                colors: [
                  _activeColors[index].withAlpha((0.8 * 255).toInt()),
                  _activeColors[index],
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(10),
        boxShadow: _currentIndex == index
            ? [
                BoxShadow(
                  color: _activeColors[index].withAlpha((0.3 * 255).toInt()),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        color: _currentIndex == index ? Colors.white : Colors.grey,
        size: 24,
      ),
    );
  }
}