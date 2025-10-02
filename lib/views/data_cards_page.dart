import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sensor_data.dart';
import '../widgets/sensor_card.dart';

class DataCardsPage extends StatefulWidget {
  const DataCardsPage({super.key});

  @override
  DataCardsPageState createState() => DataCardsPageState();
}

class DataCardsPageState extends State<DataCardsPage> with SingleTickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  SensorData sensorData = SensorData(
    temperature: 0.0,
    humidity: 0.0,
    gas: 0.0,
    flame: false,
    smoke: false,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    
    _fetchData();
    _listenToChanges();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final response = await supabase
          .from('capteurs')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      if (mounted) {
        setState(() {
          sensorData = SensorData(
            temperature: (response['temperature'] as num?)?.toDouble() ?? 0.0,
            humidity: (response['humidity'] as num?)?.toDouble() ?? 0.0,
            gas: (response['gas'] as num?)?.toDouble() ?? 0.0,
            flame: response['flame'] ?? false,
            smoke: response['smoke'] ?? false,
          );
        });
        _animationController.reset();
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _listenToChanges() {
    final channel = supabase.channel('capteurs_channel');

    channel.onBroadcast(
      event: 'INSERT',
      callback: (payload) {
        if (mounted) {
          setState(() {
            sensorData = SensorData(
              temperature: (payload['temperature'] as num?)?.toDouble() ?? 0.0,
              humidity: (payload['humidity'] as num?)?.toDouble() ?? 0.0,
              gas: (payload['gas'] as num?)?.toDouble() ?? 0.0,
              flame: payload['flame'] ?? false,
              smoke: payload['smoke'] ?? false,
            );
          });
          _animationController.reset();
          _animationController.forward();
        }
      },
    ).subscribe();
  }

  Color _getBackgroundColor(BuildContext context) {
    if (sensorData.flame || sensorData.smoke || sensorData.gas > 300 || sensorData.temperature > 40) {
      return Theme.of(context).colorScheme.errorContainer;
    } else if (sensorData.gas > 200 || sensorData.temperature > 30) {
      return Theme.of(context).colorScheme.tertiaryContainer;
    }
    return Theme.of(context).colorScheme.surfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getBackgroundColor(context),
            Theme.of(context).colorScheme.background,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Cartes des données',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchData,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Carte de statut
              Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        'STATUT DU SYSTÈME',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _StatusIndicator(
                              active: sensorData.flame,
                              label: 'Flamme',
                              icon: Icons.local_fire_department,
                            ),
                            const SizedBox(width: 16),
                            _StatusIndicator(
                              active: sensorData.smoke,
                              label: 'Fumée',
                              icon: Icons.smoke_free,
                            ),
                            const SizedBox(width: 16),
                            _StatusIndicator(
                              active: sensorData.gas > 200,
                              label: 'Gaz',
                              icon: Icons.cloud,
                            ),
                            const SizedBox(width: 16),
                            _StatusIndicator(
                              active: sensorData.temperature > 30,
                              label: 'Chaleur',
                              icon: Icons.thermostat,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Cartes des capteurs en ligne verticale
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _AnimatedSensorCard(
                      animation: _fadeAnimation,
                      delay: 0,
                      child: SensorCard(
                        icon: Icons.thermostat,
                        title: 'TEMPÉRATURE',
                        value: '${sensorData.temperature.toStringAsFixed(1)}°C',
                        color: sensorData.temperature > 30 
                            ? Colors.red 
                            : Colors.blue,
                        isCritical: sensorData.temperature > 30,
                        gradient: LinearGradient(
                          colors: [
                            sensorData.temperature > 30 
                                ? Colors.red[400]! 
                                : Colors.blue[400]!,
                            sensorData.temperature > 30 
                                ? Colors.red[800]! 
                                : Colors.blue[800]!,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AnimatedSensorCard(
                      animation: _fadeAnimation,
                      delay: 100,
                      child: SensorCard(
                        icon: Icons.water_drop,
                        title: 'HUMIDITÉ',
                        value: '${sensorData.humidity.toStringAsFixed(1)}%',
                        color: sensorData.humidity > 70 
                            ? Colors.red 
                            : Colors.green,
                        isCritical: sensorData.humidity > 70,
                        gradient: LinearGradient(
                          colors: [
                            sensorData.humidity > 70 
                                ? Colors.red[400]! 
                                : Colors.green[400]!,
                            sensorData.humidity > 70 
                                ? Colors.red[800]! 
                                : Colors.green[800]!,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AnimatedSensorCard(
                      animation: _fadeAnimation,
                      delay: 200,
                      child: SensorCard(
                        icon: Icons.cloud,
                        title: 'NIVEAU DE GAZ',
                        value: '${sensorData.gas.toStringAsFixed(1)} ppm',
                        color: sensorData.gas > 200 
                            ? Colors.red 
                            : Colors.orange,
                        isCritical: sensorData.gas > 200,
                        gradient: LinearGradient(
                          colors: [
                            sensorData.gas > 200 
                                ? Colors.red[400]! 
                                : Colors.orange[400]!,
                            sensorData.gas > 200 
                                ? Colors.red[800]! 
                                : Colors.orange[800]!,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AnimatedSensorCard(
                      animation: _fadeAnimation,
                      delay: 300,
                      child: SensorCard(
                        icon: Icons.local_fire_department,
                        title: 'DÉTECTION FLAMME',
                        value: sensorData.flame 
                            ? 'DÉTECTÉE!' 
                            : 'NORMAL',
                        color: sensorData.flame 
                            ? Colors.red 
                            : Colors.grey,
                        isCritical: sensorData.flame,
                        gradient: LinearGradient(
                          colors: [
                            sensorData.flame 
                                ? Colors.red[400]! 
                                : Colors.grey[400]!,
                            sensorData.flame 
                                ? Colors.red[800]! 
                                : Colors.grey[800]!,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AnimatedSensorCard(
                      animation: _fadeAnimation,
                      delay: 400,
                      child: SensorCard(
                        icon: Icons.smoke_free,
                        title: 'DÉTECTION FUMÉE',
                        value: sensorData.smoke 
                            ? 'DÉTECTÉE!' 
                            : 'NORMAL',
                        color: sensorData.smoke 
                            ? Colors.red 
                            : Colors.grey,
                        isCritical: sensorData.smoke,
                        gradient: LinearGradient(
                          colors: [
                            sensorData.smoke 
                                ? Colors.red[400]! 
                                : Colors.grey[400]!,
                            sensorData.smoke 
                                ? Colors.red[800]! 
                                : Colors.grey[800]!,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final bool active;
  final String label;
  final IconData icon;

  const _StatusIndicator({
    required this.active,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active 
                ? Theme.of(context).colorScheme.errorContainer 
                : Theme.of(context).colorScheme.surfaceVariant,
            border: Border.all(
              color: active 
                  ? Theme.of(context).colorScheme.error 
                  : Theme.of(context).colorScheme.outline,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: active 
                ? Theme.of(context).colorScheme.error 
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: active 
                ? Theme.of(context).colorScheme.error 
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AnimatedSensorCard extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final int delay;

  const _AnimatedSensorCard({
    required this.child,
    required this.animation,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - Curves.easeOut.transform(
            Interval(
              delay / 600,
              1.0,
              curve: Curves.easeInOut,
            ).transform(animation.value),
          )) * 20),
          child: Opacity(
            opacity: Interval(
              delay / 600,
              1.0,
              curve: Curves.easeInOut,
            ).transform(animation.value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}