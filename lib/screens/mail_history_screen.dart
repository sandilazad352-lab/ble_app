import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/time_utils.dart';
import '../providers/mail_provider.dart';

class MailHistoryScreen extends StatefulWidget {
  const MailHistoryScreen({super.key});

  @override
  State<MailHistoryScreen> createState() => _MailHistoryScreenState();
}

class _MailHistoryScreenState extends State<MailHistoryScreen> {
  final _searchController = TextEditingController();
  DateTimeRange? _dateFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MailProvider>().loadRecords();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mail = context.watch<MailProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mail History')),
      body: Column(
        children: [
          _buildSearchBar(mail),
          if (_dateFilter != null) _buildActiveFilter(mail),
          Expanded(
            child: mail.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan))
                : mail.records.isEmpty
                    ? _buildEmptyState()
                    : _buildMailList(mail),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(MailProvider mail) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search mail...',
                border: InputBorder.none,
              ),
              onChanged: mail.setSearchQuery,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.date_range, color: AppTheme.neonCyan),
            onPressed: () => _pickDateRange(mail),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilter(MailProvider mail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Chip(
        label: Text(
          '${TimeUtils.formatDateTime(_dateFilter!.start)} - ${TimeUtils.formatDateTime(_dateFilter!.end)}',
          style: const TextStyle(color: AppTheme.darkBg, fontSize: 12),
        ),
        backgroundColor: AppTheme.neonCyan,
        deleteIconColor: AppTheme.darkBg,
        onDeleted: () {
          setState(() => _dateFilter = null);
          mail.setDateFilter(null);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mail_outline, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'No mail records yet',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMailList(MailProvider mail) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: mail.records.length,
      itemBuilder: (context, index) {
        final record = mail.records[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.neonCyan.withValues(alpha: 0.1),
                  border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    '#${record.count}',
                    style: const TextStyle(
                      color: AppTheme.neonCyan,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TimeUtils.formatDateTime(record.timestamp),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (record.rssi != null)
                          _buildChip('RSSI: ${record.rssi}', AppTheme.neonBlue),
                        if (record.batteryPct != null) ...[
                          const SizedBox(width: 6),
                          _buildChip('Bat: ${record.batteryPct}%', AppTheme.neonGreen),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                TimeUtils.timeAgo(record.timestamp),
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _pickDateRange(MailProvider mail) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(data: AppTheme.darkTheme, child: child!),
    );
    if (range != null) {
      setState(() => _dateFilter = range);
      mail.setDateFilter(range);
    }
  }
}