import 'package:flutter/material.dart';
import 'feedback_form.dart'; // Importez le formulaire de feedback

class FeedbackCenterPage extends StatelessWidget {
  const FeedbackCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('Centre de Feedback', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF1E1E2F), const Color(0xFF2A2A3D)]
                : [const Color(0xFFF5F5F5), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nous aimerions avoir votre avis !',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 20),
              _buildFeedbackOption(
                context,
                icon: Icons.feedback,
                title: 'Donner votre avis',
                description: 'Partagez vos impressions sur l\'application.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FeedbackForm(
                        type: 'feedback',
                        title: 'Donner votre avis',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildFeedbackOption(
                context,
                icon: Icons.bug_report,
                title: 'Signaler un problème',
                description: 'Rencontrez-vous un bug ou un dysfonctionnement ?',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FeedbackForm(
                        type: 'bug',
                        title: 'Signaler un problème',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildFeedbackOption(
                context,
                icon: Icons.lightbulb_outline,
                title: 'Suggestions d\'amélioration',
                description: 'Avez-vous des idées pour améliorer l\'application ?',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FeedbackForm(
                        type: 'suggestion',
                        title: 'Suggestions d\'amélioration',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDarkMode ? const Color(0xFF2A2A3D) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
          ],
        ),
      ),
    );
  }
}