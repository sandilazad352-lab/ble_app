import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_theme.dart';
import '../providers/ble_provider.dart';
import '../providers/mail_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MailProvider>().loadRecords();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
          labelColor: AppTheme.neonCyan,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.neonCyan,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TodayTab(ble: ble),
          _WeeklyTab(ble: ble),
          _MonthlyTab(ble: ble),
        ],
      ),
    );
  }
}

class _TodayTab extends StatelessWidget {
  final BleProvider ble;
  const _TodayTab({required this.ble});

  @override
  Widget build(BuildContext context) {
    final mail = context.watch<MailProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          'Total Deliveries Today',
          '${ble.todayMailCount}',
          Icons.mail,
          AppTheme.neonCyan,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Total Mail Count',
          '${ble.totalMailCount}',
          Icons.all_inbox,
          AppTheme.neonPurple,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Battery Level',
          ble.batteryPercent != null ? '${ble.batteryPercent}%' : '--',
          Icons.battery_std,
          AppTheme.neonGreen,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Signal Strength',
          ble.currentRssi != null ? '${ble.currentRssi} dBm' : '--',
          Icons.wifi,
          AppTheme.neonBlue,
        ),
        const SizedBox(height: 24),
        const Text(
          'Battery Trend',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: _buildMiniChart(mail),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardGlow,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChart(MailProvider mail) {
    final records = mail.records;
    if (records.isEmpty) {
      return const Center(child: Text('No data yet', style: TextStyle(color: AppTheme.textSecondary)));
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < records.length && i < 24; i++) {
      final bat = (records[records.length - 1 - i].batteryPct ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), bat));
    }
    spots.sort((a, b) => a.x.compareTo(b.x));

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppTheme.darkBorder, strokeWidth: 1)),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, _) => Text('${v.toInt()}%', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)))),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.neonGreen,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: AppTheme.neonGreen.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }
}

class _WeeklyTab extends StatelessWidget {
  final BleProvider ble;
  const _WeeklyTab({required this.ble});

  @override
  Widget build(BuildContext context) {
    final mail = context.watch<MailProvider>();

    return FutureBuilder<Map<String, int>>(
      future: mail.getWeeklyCounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan));
        }

        final data = snapshot.data!;
        return _buildBarChart(data, 'Weekly Deliveries');
      },
    );
  }

  Widget _buildBarChart(Map<String, int> data, String title) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final bars = <BarChartGroupData>[];
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final count = data[key] ?? 0;
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: AppTheme.neonCyan,
              width: 20,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: const TextStyle(color: AppTheme.neonCyan, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: bars,
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(days[v.toInt()], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)))),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthlyTab extends StatelessWidget {
  final BleProvider ble;
  const _MonthlyTab({required this.ble});

  @override
  Widget build(BuildContext context) {
    final mail = context.watch<MailProvider>();

    return FutureBuilder<Map<String, int>>(
      future: mail.getMonthlyCounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan));
        }
        final data = snapshot.data!;
        return _buildLineChart(data);
      },
    );
  }

  Widget _buildLineChart(Map<String, int> data) {
    final sortedKeys = data.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedKeys.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[sortedKeys[i]]!.toDouble()));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Monthly Trend', style: TextStyle(color: AppTheme.neonCyan, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: spots.isEmpty
              ? const Center(child: Text('No data', style: TextStyle(color: AppTheme.textSecondary)))
              : LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppTheme.darkBorder, strokeWidth: 1)),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)))),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppTheme.neonPurple,
                        barWidth: 2,
                        dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 3, color: AppTheme.neonPurple, strokeWidth: 1, strokeColor: AppTheme.darkBg)),
                        belowBarData: BarAreaData(show: true, color: AppTheme.neonPurple.withValues(alpha: 0.1)),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}