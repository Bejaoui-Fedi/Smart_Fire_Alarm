import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class UnifiedControlPage extends StatefulWidget {
  const UnifiedControlPage({super.key});

  @override
  UnifiedControlPageState createState() => UnifiedControlPageState();
}

enum DeviceType { extincteur, ventilateur }

class DeviceState {
  bool isActive;
  DateTime? lastUpdated;
  final List<String> history;

  DeviceState({this.isActive = false, this.lastUpdated, required this.history});
}

class UnifiedControlPageState extends State<UnifiedControlPage> with SingleTickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  final String deviceId = 'ESP32_1';
  final Logger logger = Logger();
  late TabController _tabController;
  
  Map<DeviceType, DeviceState> devices = {
    DeviceType.extincteur: DeviceState(history: []),
    DeviceType.ventilateur: DeviceState(history: []),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchDeviceStates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchDeviceStates() async {
    await Future.wait([
      fetchDeviceState(DeviceType.extincteur),
      fetchDeviceState(DeviceType.ventilateur),
    ]);
  }

  Future<void> fetchDeviceState(DeviceType type) async {
    final String tableName = '${type.name}_state';
    
    try {
      final response = await supabase
          .from(tableName)
          .select()
          .eq('device_id', deviceId)
          .order('last_updated', ascending: false)
          .limit(1)
          .single();

      if (mounted) {
        setState(() {
          devices[type]!.isActive = response['is_active'] as bool;
          devices[type]!.lastUpdated = DateTime.parse(response['last_updated'] as String);
        });
      }
    } catch (e) {
      logger.e("Erreur lors de la récupération de l'état de $type : $e");
    }
  }

  Future<void> toggleDevice(DeviceType type, bool newState) async {
    final String tableName = '${type.name}_state';
    final String deviceName = type == DeviceType.extincteur ? 'Extincteur' : 'Ventilateur';
    
    try {
      await supabase.from(tableName).insert({
        'device_id': deviceId,
        'is_active': newState,
        'last_updated': DateTime.now().toUtc().toIso8601String(),
      });

      if (mounted) {
        setState(() {
          devices[type]!.isActive = newState;
          devices[type]!.lastUpdated = DateTime.now();
          devices[type]!.history.add("$deviceName ${newState ? 'activé' : 'désactivé'} à ${DateTime.now().toLocal()}");
        });
      }
    } catch (e) {
      logger.e("Erreur lors de la modification de l'état de $type : $e");
    }
  }

  Color getPrimaryColor(DeviceType type, bool isDarkMode) {
    switch (type) {
      case DeviceType.extincteur:
        return isDarkMode ? Colors.deepOrange.shade900 : Colors.orange.shade400;
      case DeviceType.ventilateur:
        return isDarkMode ? Colors.blue.shade900 : Colors.blue.shade400;
    }
  }

  Color getSecondaryColor(DeviceType type, bool isDarkMode) {
    switch (type) {
      case DeviceType.extincteur:
        return isDarkMode ? Colors.black : Colors.yellow.shade200;
      case DeviceType.ventilateur:
        return isDarkMode ? Colors.black : Colors.lightBlue.shade200;
    }
  }

  Color getIconColor(DeviceType type) {
    switch (type) {
      case DeviceType.extincteur:
        return Colors.deepOrange;
      case DeviceType.ventilateur:
        return Colors.blue;
    }
  }

  Icon getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.extincteur:
        return const Icon(Icons.local_fire_department, size: 40);
      case DeviceType.ventilateur:
        return const Icon(Icons.air, size: 40);
    }
  }

  void showHistoryDialog(BuildContext context, DeviceType type) {
    final String deviceName = type == DeviceType.extincteur ? 'Extincteur' : 'Ventilateur';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Historique du $deviceName'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: devices[type]!.history.isEmpty
              ? Center(child: Text('Aucun historique pour le $deviceName'))
              : ListView.builder(
                  itemCount: devices[type]!.history.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: Icon(Icons.history, color: getIconColor(type)),
                    title: Text(devices[type]!.history[index]),
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contrôle des Appareils",
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
                  ? [Colors.deepPurple.shade900, Colors.black]
                  : [Colors.deepPurple.shade400, Colors.purple.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: const Icon(Icons.local_fire_department),
              text: "Extincteur",
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
            Tab(
              icon: const Icon(Icons.air),
              text: "Ventilateur",
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDeviceTab(DeviceType.extincteur, isDarkMode),
          _buildDeviceTab(DeviceType.ventilateur, isDarkMode),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Contrôle Rapide'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuickControlButton(
                    context,
                    DeviceType.extincteur,
                    devices[DeviceType.extincteur]!.isActive,
                  ),
                  const SizedBox(height: 16),
                  _buildQuickControlButton(
                    context,
                    DeviceType.ventilateur,
                    devices[DeviceType.ventilateur]!.isActive,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.dashboard_customize),
      ),
    );
  }

  Widget _buildQuickControlButton(BuildContext context, DeviceType type, bool isActive) {
    final String deviceName = type == DeviceType.extincteur ? 'Extincteur' : 'Ventilateur';
    
    return ListTile(
      leading: getDeviceIcon(type),
      title: Text(deviceName),
      subtitle: Text(isActive ? 'Activé' : 'Désactivé'),
      trailing: Switch(
        value: isActive,
        activeColor: getIconColor(type),
        onChanged: (value) {
          toggleDevice(type, value);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildDeviceTab(DeviceType type, bool isDarkMode) {
    final primaryColor = getPrimaryColor(type, isDarkMode);
    final secondaryColor = getSecondaryColor(type, isDarkMode);
    final deviceState = devices[type]!;
    final String deviceName = type == DeviceType.extincteur ? 'Extincteur' : 'Ventilateur';
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Carte unique contenant à la fois le contrôle et l'historique
              Expanded(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section du contrôle d'appareil
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: deviceState.isActive ? Colors.green : Colors.red,
                                  boxShadow: [
                                    BoxShadow(
                                      color: deviceState.isActive 
                                          ? Colors.green.withOpacity(0.5) 
                                          : Colors.red.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    deviceState.isActive ? Icons.check_circle : Icons.cancel,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "$deviceName ${deviceState.isActive ? 'activé' : 'désactivé'}",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: deviceState.isActive ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                deviceState.lastUpdated != null 
                                    ? "Dernière mise à jour: ${deviceState.lastUpdated!.toLocal().toString().substring(0, 19)}"
                                    : "Pas de données",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: 200,
                                child: ElevatedButton.icon(
                                  onPressed: () => toggleDevice(type, !deviceState.isActive),
                                  icon: Icon(
                                    deviceState.isActive ? Icons.power_settings_new : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    deviceState.isActive ? "Désactiver" : "Activer",
                                    style: const TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: deviceState.isActive ? Colors.red : Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Divider(thickness: 1),
                        
                        // Section de l'historique
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Historique des actions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.refresh,
                                color: getIconColor(type),
                              ),
                              onPressed: () => fetchDeviceState(type),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Liste d'historique
                        Expanded(
                          child: deviceState.history.isEmpty
                              ? Center(
                                  child: Text('Aucun historique pour le $deviceName'),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: deviceState.history.length,
                                  itemBuilder: (context, index) {
                                    final reversedIndex = deviceState.history.length - 1 - index;
                                    return Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.history,
                                          color: getIconColor(type),
                                        ),
                                        title: Text(deviceState.history[reversedIndex]),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        // Bouton pour voir tout l'historique
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: OutlinedButton.icon(
                            onPressed: () => showHistoryDialog(context, type),
                            icon: const Icon(Icons.fullscreen),
                            label: const Text('Voir tout l\'historique'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: getIconColor(type),
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
}