import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _imageFile; // Pour stocker l'image sélectionnée
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.userMetadata?['name'] ?? '';
        _emailController.text = user.email ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        String? avatarUrl;

        // Télécharger la nouvelle photo de profil si une image a été sélectionnée
        if (_imageFile != null) {
          final fileExtension = _imageFile!.path.split('.').last;
          final fileName = '${user.id}.$fileExtension';
          final filePath = '${user.id}/$fileName'; // Dossier spécifique à l'utilisateur

          // Télécharger le fichier dans le bucket 'avatars'
          await supabase.storage
              .from('avatars')
              .upload(filePath, _imageFile!);

          // Récupérer l'URL publique du fichier
          avatarUrl = supabase.storage
              .from('avatars')
              .getPublicUrl(filePath); // Pas besoin de .data.publicUrl
        }

        // Mettre à jour les métadonnées de l'utilisateur
        await supabase.auth.updateUser(
          UserAttributes(
            data: {
              'name': _nameController.text,
              if (avatarUrl != null) 'avatar_url': avatarUrl,
            },
          ),
        );

        // Recharger les données de l'utilisateur
        await supabase.auth.refreshSession();

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès !')),
        );

        // Revenir à la page précédente
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour du profil : $e')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = Supabase.instance.client.auth.currentUser?.userMetadata?['avatar_url'] as String?;

    // Couleurs dynamiques en fonction du mode sombre ou clair
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final appBarColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le profil', style: TextStyle(color: textColor)),
        backgroundColor: appBarColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      backgroundColor: backgroundColor, // Arrière-plan dynamique
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Photo de profil avec effet de superposition
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : avatarUrl != null
                            ? NetworkImage(avatarUrl)
                            : null,
                    child: _imageFile == null && avatarUrl == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: appBarColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.edit, size: 20, color: textColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Champ de formulaire pour le nom
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 16),
            // Champ de formulaire pour l'email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 24),
            // Bouton de sauvegarde
            _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appBarColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Sauvegarder',
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}