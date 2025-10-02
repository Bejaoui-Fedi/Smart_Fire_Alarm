import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class FireRisk {
  final String id;
  final String? capteurId;
  final DateTime analysisTime;
  final double riskScore;
  final String riskLevel;
  final bool isFirePredicted;

  FireRisk({
    required this.id,
    this.capteurId,
    required this.analysisTime,
    required this.riskScore,
    required this.riskLevel,
    required this.isFirePredicted,
  });

  factory FireRisk.fromJson(Map<String, dynamic> json) {
    return FireRisk(
      id: json['id'] as String,
      capteurId: json['capteur_id'] as String?,
      analysisTime: DateTime.parse(json['analysis_time'] as String),
      riskScore: _safeParseDouble(json['risk_score']),
      riskLevel: json['risk_level'] as String? ?? 'unknown',
      isFirePredicted: json['is_fire_predicted'] as bool? ?? false,
    );
  }

  static double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

class FireRiskListView extends StatelessWidget {
  final SupabaseClient _supabase = Supabase.instance.client;

  FireRiskListView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _supabase
          .from('fire_risk_analysis')
          .select('*')
          .order('analysis_time', ascending: false)
          .limit(100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        final risks = snapshot.data!
            .map((json) => FireRisk.fromJson(json))
            .toList();

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: risks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final risk = risks[index];
            return _buildRiskCard(context, risk);
          },
        );
      },
    );
  }

  Widget _buildRiskCard(BuildContext context, FireRisk risk) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: risk.isFirePredicted 
                    ? Colors.red.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  risk.isFirePredicted ? Icons.warning : Icons.check_circle,
                  color: risk.isFirePredicted ? Colors.red : Colors.green,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Capteur ${risk.capteurId ?? 'N/A'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy - HH:mm').format(risk.analysisTime),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getRiskColor(risk.riskLevel),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      risk.riskLevel.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${risk.riskScore.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }
}

class FireRiskAnalysisScreen extends StatelessWidget {
  const FireRiskAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Analyse des Risques', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FireRiskListView(),
    );
  }
}