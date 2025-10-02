import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sign_in_page.dart'; // Importez la classe SignInPage ici

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key});

  @override
  _AccountManagementPageState createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController newEmailController = TextEditingController();
  bool isChangingPassword = false;
  bool isUpdatingEmail = false;
  bool showChangePasswordSection = false; // Pour afficher/masquer la section "Changer le mot de passe"
  bool showUpdateEmailSection = false; // Pour afficher/masquer la section "Mettre à jour l'email"

  Future<void> _changePassword() async {
    if (oldPasswordController.text.isEmpty || newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    setState(() {
      isChangingPassword = true;
    });

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPasswordController.text),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe changé avec succès !')),
      );
      oldPasswordController.clear();
      newPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      setState(() {
        isChangingPassword = false;
      });
    }
  }

  Future<void> _updateEmail() async {
    if (newEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un email valide.')),
      );
      return;
    }

    setState(() {
      isUpdatingEmail = true;
    });

    try {
      await supabase.auth.updateUser(
        UserAttributes(email: newEmailController.text),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email mis à jour avec succès !')),
      );
      newEmailController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      setState(() {
        isUpdatingEmail = false;
      });
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le compte'),
          content: const Text('Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
  onPressed: () async {
    try {
      await supabase.rpc('delete_user'); // 🔁 ici, utilisez rpc() au lieu de functions.invoke
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte supprimé avec succès !')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  },
  child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
),

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion du compte'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Changer le mot de passe
          Card(
            elevation: 2,
            child: ExpansionTile(
              leading: const Icon(Icons.lock),
              title: const Text('Changer le mot de passe'),
              initiallyExpanded: showChangePasswordSection,
              onExpansionChanged: (expanded) {
                setState(() {
                  showChangePasswordSection = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      TextField(
                        controller: oldPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Ancien mot de passe',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Nouveau mot de passe',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isChangingPassword ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: isChangingPassword
                            ? const CircularProgressIndicator()
                            : const Text('Changer le mot de passe'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section Mettre à jour l'email
          Card(
            elevation: 2,
            child: ExpansionTile(
              leading: const Icon(Icons.email),
              title: const Text('Mettre à jour l\'email'),
              initiallyExpanded: showUpdateEmailSection,
              onExpansionChanged: (expanded) {
                setState(() {
                  showUpdateEmailSection = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      TextField(
                        controller: newEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Nouvel email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isUpdatingEmail ? null : _updateEmail,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: isUpdatingEmail
                            ? const CircularProgressIndicator()
                            : const Text('Mettre à jour l\'email'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section Supprimer le compte
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Supprimer le compte',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                _deleteAccount(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}