import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sign_in_page.dart';
import 'appearance_settings_page.dart';
import 'notification_settings_page.dart';
import 'account_management_page.dart';
import 'privacy_security_page.dart';
import 'edit_profile_page.dart';
import 'feedback_center_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<GlobalKey> _tileKeys = List.generate(5, (_) => GlobalKey());
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signOut(BuildContext context) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.auth.signOut();
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Déconnexion réussie !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    // Couleurs dynamiques en fonction du mode sombre ou clair
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? const Color(0xFF1E1E2F)
        : const Color(0xFFF5F5F5);

    final surfaceColor = isDarkMode
        ? const Color(0xFF2A2A3D)
        : Colors.white;

    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFF6E44FF);
    
    // Dégradé amélioré pour l'arrière-plan
    final backgroundGradient = LinearGradient(
      colors: isDarkMode
          ? [const Color(0xFF1E1E2F), const Color(0xFF252538)]
          : [const Color(0xFFF8F9FF), const Color(0xFFEEF1FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Paramètres',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section Profil Utilisateur - Design amélioré
                _buildProfileCard(context, user, avatarUrl, surfaceColor, textColor, accentColor),
                const SizedBox(height: 24),
                
                // Section des paramètres avec animation
                ..._buildAnimatedSettingsSections(surfaceColor, textColor, accentColor),
                
                const SizedBox(height: 32),
                
                // Bouton de déconnexion amélioré
                _buildSignOutButton(context, accentColor),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    User? user,
    String? avatarUrl,
    Color surfaceColor,
    Color textColor,
    Color accentColor,
  ) {
    return Hero(
      tag: 'profile-card',
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
            },
            splashColor: accentColor.withOpacity(0.1),
            highlightColor: accentColor.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildAvatarWithBorder(avatarUrl, accentColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.email?.split('@').first ?? 'Utilisateur',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit,
                                size: 14,
                                color: accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Modifier le profil',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: accentColor,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWithBorder(String? avatarUrl, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [accentColor, accentColor.withBlue(220)],
        ),
      ),
      child: CircleAvatar(
        radius: 32,
        backgroundColor: Colors.white,
        backgroundImage: avatarUrl != null
            ? NetworkImage('$avatarUrl?${DateTime.now().millisecondsSinceEpoch}')
            : null,
        child: avatarUrl == null
            ? const Icon(Icons.person, size: 32, color: Color(0xFF6E44FF))
            : null,
      ),
    );
  }

  List<Widget> _buildAnimatedSettingsSections(
    Color surfaceColor,
    Color textColor,
    Color accentColor,
  ) {
    final settingsData = [
      {
        'icon': Icons.color_lens_outlined,
        'title': 'Apparence',
        'subtitle': 'Thème, couleurs et affichage',
        'destination': const AppearanceSettingsPage(),
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notifications',
        'subtitle': 'Sons, alertes et rappels',
        'destination': const NotificationSettingsPage(),
      },
      {
        'icon': Icons.account_circle_outlined,
        'title': 'Gestion du compte',
        'subtitle': 'Informations personnelles',
        'destination': const AccountManagementPage(),
      },
      {
        'icon': Icons.security_outlined,
        'title': 'Confidentialité et sécurité',
        'subtitle': 'Mot de passe et confidentialité',
        'destination': const PrivacySecurityPage(),
      },
      {
        'icon': Icons.feedback_outlined,
        'title': 'Centre de Feedback',
        'subtitle': 'Aide et suggestions',
        'destination': const FeedbackCenterPage(),
      },
    ];

    return List.generate(settingsData.length, (index) {
      final data = settingsData[index];
      final delay = index * 100;
      
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final start = delay / 1000;
          final end = start + 0.5;
          final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutQuart),
            ),
          );
          
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.2, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          key: _tileKeys[index],
          child: _buildSettingTile(
            context,
            icon: data['icon'] as IconData,
            title: data['title'] as String,
            subtitle: data['subtitle'] as String,
            destination: data['destination'] as Widget,
            surfaceColor: surfaceColor,
            textColor: textColor,
            accentColor: accentColor,
          ),
        ),
      );
    });
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget destination,
    required Color surfaceColor,
    required Color textColor,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          },
          splashColor: accentColor.withOpacity(0.1),
          highlightColor: accentColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: accentColor.withOpacity(0.7),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, Color accentColor) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animation = CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
        );
        
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: ElevatedButton(
        onPressed: () => _signOut(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Déconnexion',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }


}