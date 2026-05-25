import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/time_utils.dart';
import '../data/models/connection_info.dart';
import '../providers/ble_provider.dart';
import '../widgets/activity_indicator.dart';
import '../widgets/battery_widget.dart';
import '../widgets/connection_indicator.dart';
import '../widgets/mail_counter.dart';
import '../widgets/neon_button.dart';
import 'analytics_screen.dart';
import 'debug_screen.dart';
import 'mail_history_screen.dart';
import 'proximity_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _DashboardPage(),
      const MailHistoryScreen(),
      const ProximityScreen(),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.near_me_outlined),
            activeIcon: Icon(Icons.near_me),
            label: 'Proximity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.small(
              backgroundColor: AppTheme.darkSurface,
              foregroundColor: AppTheme.neonCyan,
              child: const Icon(Icons.bug_report),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DebugScreen()),
              ),
            )
          : null,
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleProvider>();

    return SafeArea(
      child: RefreshIndicator(
        color: AppTheme.neonCyan,
        backgroundColor: AppTheme.darkCard,
        onRefresh: () async {
          if (ble.isConnected) {
            await ble.requestConfig();
          } else {
            ble.startScan();
          }
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ConnectionIndicator(
                    status: ble.connection.status,
                    deviceName: ble.connection.deviceName,
                    rssi: ble.currentRssi,
                  ),
                  if (ble.connection.status != ConnectionStatus.connected)
                    NeonButton(
                      label: ble.connection.status == ConnectionStatus.scanning
                          ? 'Scanning'
                          : 'Connect',
                      onTap: ble.startScan,
                      color: AppTheme.neonCyan,
                      isLoading: ble.connection.status == ConnectionStatus.scanning ||
                          ble.connection.status == ConnectionStatus.connecting,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(child: MailCounter(count: ble.totalMailCount, isActive: ble.isActivityActive)),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BatteryWidget(
                percentage: ble.batteryPercent,
                voltageMv: ble.batteryMv,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildInfoGrid(ble),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLastMail(ble),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(BleProvider ble) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.8,
      children: [
        _InfoCard(
          icon: Icons.mail_outline,
          label: 'Today',
          value: '${ble.todayMailCount}',
          color: AppTheme.neonCyan,
        ),
        _InfoCard(
          icon: ble.proximityStatus == 'NEAR'
              ? Icons.near_me
              : Icons.directions_walk,
          label: 'Proximity',
          value: ble.proximityStatus,
          color: ble.proximityStatus == 'NEAR' ? AppTheme.neonGreen : AppTheme.neonPurple,
        ),
        _InfoCard(
          icon: Icons.wifi,
          label: 'RSSI',
          value: ble.currentRssi != null ? '${ble.currentRssi} dBm' : '--',
          color: AppTheme.neonBlue,
        ),
        _InfoCard(
          icon: Icons.schedule,
          label: 'Device Time',
          value: ble.deviceTime != null
              ? TimeUtils.formatTime(ble.deviceTime!)
              : '--',
          color: AppTheme.neonPurple,
        ),
      ],
    );
  }

  Widget _buildLastMail(BleProvider ble) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardGlow,
      child: Row(
        children: [
          const Icon(Icons.schedule, color: AppTheme.neonCyan, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Last Mail Received',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ble.lastMailTime != null
                      ? TimeUtils.formatDateTime(ble.lastMailTime!)
                      : 'No mail yet',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ActivityIndicator(isActive: ble.isActivityActive, label: 'LIVE'),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}