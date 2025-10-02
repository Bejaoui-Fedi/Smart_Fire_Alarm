import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class ExtincteurPage extends StatefulWidget {
  const ExtincteurPage({super.key});

  @override
  ExtincteurPageState createState() => ExtincteurPageState();
}

class ExtincteurPageState extends State<ExtincteurPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool isActive = false;
  DateTime? lastUpdated;
  final String deviceId = 'ESP32_1';
  final Logger logger = Logger();
  final List<String> history = [];

  @override
  void initState() {
    super.initState();
    fetchExtincteurState();
  }

  Future<void> fetchExtincteurState() async {
    try {
      final response = await supabase
          .from('extincteur_state')
          .select()
          .eq('device_id', deviceId)
          .order('last_updated', ascending: false)
          .limit(1)
          .single();

      if (mounted) {
        setState(() {
          isActive = response['is_active'] as bool;
          lastUpdated = DateTime.parse(response['last_updated'] as String);
        });
      }
    } catch (e) {
      logger.e("Erreur : $e");
    }
  }

  Future<void> toggleExtincteur(bool newState) async {
    try {
      await supabase.from('extincteur_state').insert({
        'device_id': deviceId,
        'is_active': newState,
        'last_updated': DateTime.now().toUtc().toIso8601String(),
      });

      if (mounted) {
        setState(() {
          isActive = newState;
          lastUpdated = DateTime.now();
          history.add("Extincteur ${newState ? 'activé' : 'désactivé'} à ${DateTime.now()}");
        });
      }
    } catch (e) {
      logger.e("Erreur : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Contrôle de l'extincteur",
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
              colors: isDarkMode
                  ? [Colors.deepOrange.shade900, Colors.black]
                  : [Colors.orange.shade400, Colors.yellow.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => showHistoryDialog(context),
          ),
        ],
      ),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? Colors.green : Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: isActive ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          isActive ? Icons.check_circle : Icons.cancel,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isActive ? "Extincteur activé" : "Extincteur désactivé",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        lastUpdated != null 
                            ? "Dernière mise à jour: ${lastUpdated!.toLocal().toString()}"
                            : "Pas de données",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => toggleExtincteur(!isActive),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? Colors.red : Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          isActive ? "Désactiver" : "Activer",
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Text(
                          'Historique des actions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: history.length,
                            itemBuilder: (context, index) => ListTile(
                              leading: const Icon(
                                Icons.history,
                                color: Colors.deepPurple,
                              ),
                              title: Text(history[index]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historique des actions'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.history),
              title: Text(history[index]),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

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
              ? [Colors.deepOrange.shade900, Colors.black]
              : [Colors.orange.shade400, Colors.yellow.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}