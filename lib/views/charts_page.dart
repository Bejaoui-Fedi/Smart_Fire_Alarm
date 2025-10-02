import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animations/animations.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  ChartsPageState createState() => ChartsPageState();
}

class ChartsPageState extends State<ChartsPage> with TickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<SensorDataPoint> temperatureData = [];
  List<SensorDataPoint> humidityData = [];
  List<SensorDataPoint> gasData = [];
  
  bool isLoading = true;
  bool isRealtime = true;
  int selectedTimeFrame = 10; // 10 points by default

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    _fetchHistoricalData();
    _listenToRealtimeChanges();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    supabase.removeAllChannels();
    super.dispose();
  }

  Future<void> _fetchHistoricalData() async {
    setState(() => isLoading = true);
    
    try {
      final response = await supabase
          .from('capteurs')
          .select()
          .order('created_at', ascending: false)
          .limit(selectedTimeFrame);

      if (response.isNotEmpty) {
        setState(() {
          temperatureData = response.map<SensorDataPoint>((data) {
            return SensorDataPoint(
              value: (data['temperature'] as num?)?.toDouble() ?? 0.0,
              timestamp: DateTime.parse(data['created_at']),
            );
          }).toList();

          humidityData = response.map<SensorDataPoint>((data) {
            return SensorDataPoint(
              value: (data['humidity'] as num?)?.toDouble() ?? 0.0,
              timestamp: DateTime.parse(data['created_at']),
            );
          }).toList();

          gasData = response.map<SensorDataPoint>((data) {
            return SensorDataPoint(
              value: (data['gas'] as num?)?.toDouble() ?? 0.0,
              timestamp: DateTime.parse(data['created_at']),
            );
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Erreur historique: $e');
    } finally {
      setState(() => isLoading = false);
      _fadeController.forward();
    }
  }

  void _listenToRealtimeChanges() {
    final channel = supabase.channel('capteurs_channel');
    channel.onBroadcast(
      event: 'INSERT',
      callback: (payload) {
        if (mounted && isRealtime) {
          setState(() {
            final timestamp = DateTime.parse(payload['created_at'] ?? DateTime.now().toIso8601String());
            final temp = (payload['temperature'] as num?)?.toDouble() ?? 0.0;
            final hum = (payload['humidity'] as num?)?.toDouble() ?? 0.0;
            final gas = (payload['gas'] as num?)?.toDouble() ?? 0.0;

            temperatureData.insert(0, SensorDataPoint(value: temp, timestamp: timestamp));
            humidityData.insert(0, SensorDataPoint(value: hum, timestamp: timestamp));
            gasData.insert(0, SensorDataPoint(value: gas, timestamp: timestamp));

            if (temperatureData.length > selectedTimeFrame) temperatureData.removeLast();
            if (humidityData.length > selectedTimeFrame) humidityData.removeLast();
            if (gasData.length > selectedTimeFrame) gasData.removeLast();
          });
        }
      },
    ).subscribe();
  }

  Future<void> _refreshData() async {
    _fadeController.reset();
    await _fetchHistoricalData();
  }

  void _changeTimeframe(int newTimeframe) {
    setState(() {
      selectedTimeFrame = newTimeframe;
    });
    _fetchHistoricalData();
  }

  void _toggleRealtime() {
    setState(() {
      isRealtime = !isRealtime;
    });
    
    if (isRealtime) {
      _listenToRealtimeChanges();
    } else {
      supabase.removeAllChannels();
    }
  }

  Widget _buildFilterChip(String label, int timeframe) {
    return FilterChip(
      label: Text(label),
      selected: selectedTimeFrame == timeframe,
      onSelected: (_) => _changeTimeframe(timeframe),
      backgroundColor: Colors.white.withOpacity(0.1),
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 12,
      ),
    );
  }

  Widget _buildAnimatedChartCard({
    required String title,
    required List<SensorDataPoint> data,
    required Color primaryColor,
    required String unit,
  }) {
    double minY = data.isEmpty ? 0 : data.map((e) => e.value).reduce((a, b) => a < b ? a : b) * 0.8;
    double maxY = data.isEmpty ? 100 : data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2;
    
    // Ensure we have a reasonable range
    if (maxY - minY < 10) {
      minY = minY - 5;
      maxY = maxY + 5;
    }
    
    return OpenContainer(
      closedBuilder: (context, action) {
        return GlassmorphicContainer(
          width: double.infinity,
          height: 220,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.1),
              primaryColor.withOpacity(0.05),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.5),
              Colors.white.withOpacity(0.1),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data.isNotEmpty ? '${data.first.value.toStringAsFixed(1)}$unit' : 'N/A',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipRoundedRadius: 8,
                          tooltipMargin: 8,
                          getTooltipColor: (touchedSpot) => Colors.black.withOpacity(0.8),
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((spot) {
                              final index = spot.spotIndex;
                              if (index >= 0 && index < data.length) {
                                return LineTooltipItem(
                                  '${data[index].value.toStringAsFixed(1)}$unit\n',
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(
                                      text: _formatTimestamp(data[index].timestamp),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                );
                              }
                              return null;
                            }).toList();
                          },
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: (maxY - minY) / 4,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.white.withOpacity(0.1),
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value == minY || value == maxY) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: data.length - 1.0,
                      minY: minY,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.value);
                          }).toList(),
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: primaryColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                primaryColor.withOpacity(0.4),
                                primaryColor.withOpacity(0.0),
                              ],
                            ),
                          ),
                          dotData: FlDotData(
                            show: true,
                            checkToShowDot: (spot, barData) => 
                              spot.x == 0 || spot.x == data.length - 1,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: primaryColor,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      openBuilder: (context, action) {
        return _ChartDetailPage(
          title: title,
          data: data,
          primaryColor: primaryColor,
          unit: unit,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
      closedElevation: 0,
      closedColor: Colors.transparent,
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Graphes en Temps réel'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isRealtime ? Icons.sync : Icons.sync_disabled),
            tooltip: isRealtime ? 'Désactiver temps réel' : 'Activer temps réel',
            onPressed: _toggleRealtime,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              child: Column(
                children: [
                  // Timeframe selector
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Wrap(
                      spacing: 8.0,
                      children: [
                        _buildFilterChip('10 points', 10),
                        _buildFilterChip('20 points', 20),
                        _buildFilterChip('30 points', 30),
                      ],
                    ),
                  ),
                  _buildAnimatedChartCard(
                    title: 'Température',
                    data: temperatureData,
                    primaryColor: Colors.blueAccent,
                    unit: '°C',
                  ),
                  const SizedBox(height: 20),
                  _buildAnimatedChartCard(
                    title: 'Humidité',
                    data: humidityData,
                    primaryColor: Colors.greenAccent,
                    unit: '%',
                  ),
                  const SizedBox(height: 20),
                  _buildAnimatedChartCard(
                    title: 'Concentration de Gaz',
                    data: gasData,
                    primaryColor: Colors.orangeAccent,
                    unit: 'ppm',
                  ),
                ],
              ),
            ),
          ),
      ),
      bottomNavigationBar: isLoading ? null : _buildInfoBar(),
    );
  }
  
  Widget _buildInfoBar() {
    return Container(
      height: 30,
      color: Colors.black.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRealtime ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isRealtime ? 'Temps réel activé' : 'Temps réel désactivé',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            'Affichage: $selectedTimeFrame points',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartDetailPage extends StatefulWidget {
  final String title;
  final List<SensorDataPoint> data;
  final Color primaryColor;
  final String unit;

  const _ChartDetailPage({
    required this.title,
    required this.data,
    required this.primaryColor,
    required this.unit,
  });

  @override
  _ChartDetailPageState createState() => _ChartDetailPageState();
}

class _ChartDetailPageState extends State<_ChartDetailPage> {
  double touchedValue = -1;
  int touchedIndex = -1;
  bool showAverage = false;

  @override
  Widget build(BuildContext context) {
    double minY;
  double maxY;
  
  if (widget.data.isEmpty) {
    minY = 0.0;
    maxY = 100.0;
  } else {
    minY = widget.data.map((e) => e.value).reduce((a, b) => a < b ? a : b) * 0.8;
    maxY = widget.data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2;
  }
  
  double average = 0.0;
  if (widget.data.isNotEmpty) {
    average = widget.data.map((e) => e.value).reduce((a, b) => a + b) / widget.data.length;
  }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.primaryColor.withOpacity(0.2),
        actions: [
          IconButton(
            icon: Icon(showAverage ? Icons.show_chart : Icons.stacked_line_chart),
            tooltip: showAverage ? 'Masquer la moyenne' : 'Afficher la moyenne',
            onPressed: () {
              setState(() {
                showAverage = !showAverage;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: Center(
          child: GlassmorphicContainer(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            borderRadius: 20,
            blur: 20,
            alignment: Alignment.center,
            border: 2,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.primaryColor.withOpacity(0.1),
                widget.primaryColor.withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.1),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'Historique ${widget.title}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                            if (event is FlPanEndEvent || event is FlTapUpEvent) {
                              setState(() {
                                touchedValue = -1;
                                touchedIndex = -1;
                              });
                              return;
                            }
                            
                            if (touchResponse == null || touchResponse.lineBarSpots == null || 
                                touchResponse.lineBarSpots!.isEmpty) {
                              return;
                            }
                            
                            final spot = touchResponse.lineBarSpots!.first;
                            setState(() {
                              touchedValue = spot.y;
                              touchedIndex = spot.spotIndex;
                            });
                          },
                          touchTooltipData: LineTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipRoundedRadius: 8,
                            tooltipMargin: 8,
                            getTooltipColor: (touchedSpot) => Colors.black.withOpacity(0.8),
                            getTooltipItems: (List<LineBarSpot> touchedSpots) {
                              return touchedSpots.map((spot) {
                                final index = spot.spotIndex;
                                if (index >= 0 && index < widget.data.length) {
                                  final timestamp = widget.data[index].timestamp;
                                  return LineTooltipItem(
                                    '${widget.data[index].value.toStringAsFixed(1)}${widget.unit}\n',
                                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text: '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}\n',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${timestamp.day}/${timestamp.month}/${timestamp.year}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return null;
                              }).toList();
                            },
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.white.withOpacity(0.1),
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.white.withOpacity(0.1),
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}${widget.unit}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < widget.data.length) {
                                  final timestamp = widget.data[value.toInt()].timestamp;
                                  if (value.toInt() % 3 == 0) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 10,
                                        ),
                                      ),
                                    );
                                  }
                                }
                                return const SizedBox();
                              },
                              reservedSize: 30,
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        minX: 0,
                        maxX: widget.data.length - 1.0,
                        minY: minY,
                        maxY: maxY,
                        lineBarsData: [
                          // Main data line
                          LineChartBarData(
                            spots: widget.data.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value.value);
                            }).toList(),
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: widget.primaryColor,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  widget.primaryColor.withOpacity(0.3),
                                  widget.primaryColor.withOpacity(0.1),
                                ],
                              ),
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: touchedIndex == index ? 6 : 4,
                                  color: touchedIndex == index ? Colors.white : widget.primaryColor.withOpacity(0.8),
                                  strokeWidth: 2,
                                  strokeColor: widget.primaryColor,
                                );
                              },
                            ),
                          ),
                          // Average line (conditionally displayed)
                          if (showAverage)
                            LineChartBarData(
                              spots: List.generate(widget.data.length, (index) {
                                return FlSpot(index.toDouble(), average);
                              }),
                              isCurved: false,
                              color: Colors.redAccent,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              dashArray: [5, 5],
                            ),
                        ],
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            if (touchedValue >= 0)
                              HorizontalLine(
                                y: touchedValue,
                                color: Colors.white.withOpacity(0.5),
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              ),
                          ],
                          verticalLines: [
                            if (touchedIndex >= 0)
                              VerticalLine(
                                x: touchedIndex.toDouble(),
                                color: Colors.white.withOpacity(0.5),
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('Actuelle', widget.data.isNotEmpty ? widget.data.first.value : 0, widget.unit),
                      _buildStatCard('Moyenne', average, widget.unit),
                      _buildStatCard('Max', widget.data.isNotEmpty ? widget.data.map((e) => e.value).reduce((a, b) => a > b ? a : b) : 0, widget.unit),
                      _buildStatCard('Min', widget.data.isNotEmpty ? widget.data.map((e) => e.value).reduce((a, b) => a < b ? a : b) : 0, widget.unit),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, double value, String unit) {
    return GlassmorphicContainer(
      width: 80,
      height: 60,
      borderRadius: 12,
      blur: 10,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.02),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Classe pour structurer les données des capteurs
class SensorDataPoint {
  final double value;
  final DateTime timestamp;

  SensorDataPoint({required this.value, required this.timestamp});
}