import 'package:flutter/material.dart';
import 'package:smart_fire_alarm/views/sign_in_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  _PrivacySecurityPageState createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> loginHistory = [];
  bool isLoading = false;
  bool isTwoFactorEnabled = false; // État de la 2FA
  bool showLoginHistory = false; // Pour afficher/masquer l'historique de connexion

  @override
  void initState() {
    super.initState();
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      // Rediriger vers la page de connexion si l'utilisateur n'est pas connecté
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => SignInPage(),
        ));
      });
    } else {
      _loadTwoFactorAuthState(); // Charger l'état de la 2FA au démarrage
    }
  }

  // Charger l'état de la 2FA depuis Supabase
  Future<void> _loadTwoFactorAuthState() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('user_settings')
          .select('two_factor_enabled')
          .eq('user_id', userId)
          .maybeSingle(); // Utilisez maybeSingle pour éviter une erreur si aucun enregistrement n'existe

      if (response != null) {
        setState(() {
          isTwoFactorEnabled = response['two_factor_enabled'] ?? false; // Assurez-vous que le nom de la colonne est correct
        });
      } else {
        // Aucun enregistrement trouvé, créez un enregistrement par défaut
        await supabase
            .from('user_settings')
            .upsert({
              'user_id': userId,
              'two_factor_enabled': false,
            })
            .eq('user_id', userId);

        setState(() {
          isTwoFactorEnabled = false; // Par défaut, la 2FA est désactivée
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement de la 2FA : $e')),
      );
    }
  }

  // Activer/désactiver la 2FA
  Future<void> _toggleTwoFactorAuth(bool value) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Utilisateur non connecté')),
    );
    return;
  }

  try {
    await supabase
        .from('user_settings')
        .upsert({
          'user_id': userId,
          'two_factor_enabled': value,
        },
        onConflict: 'user_id'); // ✅ ici aussi

    setState(() {
      isTwoFactorEnabled = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('2FA ${value ? 'activée' : 'désactivée'} avec succès !')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur : $e')),
    );
  }
}


  // Charger l'historique de connexion
  Future<void> _loadLoginHistory() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur non connecté')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase
          .from('login_history')
          .select()
          .eq('user_id', userId);

      setState(() {
        loginHistory = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confidentialité et sécurité'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 2FA
          Card(
            elevation: 2,
            child: SwitchListTile(
              title: const Text('Authentification à deux facteurs (2FA)'),
              value: isTwoFactorEnabled,
              onChanged: (value) {
                _toggleTwoFactorAuth(value);
              },
              secondary: const Icon(Icons.security),
            ),
          ),
          const SizedBox(height: 16),

          // Section Historique de connexion
          Card(
            elevation: 2,
            child: ExpansionTile(
              leading: const Icon(Icons.history),
              title: const Text('Historique de connexion'),
              initiallyExpanded: showLoginHistory,
              onExpansionChanged: (expanded) {
                setState(() {
                  showLoginHistory = expanded;
                  if (expanded) _loadLoginHistory();
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (loginHistory.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Historique de connexion :',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...loginHistory.map((login) {
                              return ListTile(
                                title: Text('Connecté le ${login['login_time']}'),
                                
                                dense: true,
                              );
                            }).toList(),
                          ],
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'Aucun historique de connexion disponible.',
                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}