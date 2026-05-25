import 'package:flutter/material.dart';
import '../data/models/mail_record.dart';
import '../data/repositories/mail_repository.dart';

class MailProvider extends ChangeNotifier {
  final MailRepository _repo = MailRepository();

  List<MailRecord> _records = [];
  List<MailRecord> _filteredRecords = [];
  bool _isLoading = false;
  String _searchQuery = '';
  DateTimeRange? _dateFilter;
  int _totalCount = 0;

  List<MailRecord> get records => _dateFilter != null || _searchQuery.isNotEmpty
      ? _filteredRecords
      : _records;
  bool get isLoading => _isLoading;
  int get totalCount => _totalCount;

  Future<void> loadRecords({int limit = 100}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _records = await _repo.getAll(limit: limit);
      _totalCount = await _repo.getTotalCount();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading mail records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecord(MailRecord record) async {
    await _repo.addRecord(record);
    _totalCount++;
    _records.insert(0, record);
    if (_records.length > 100) _records.removeLast();
    _applyFilters();
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repo.deleteAll();
    _records.clear();
    _filteredRecords.clear();
    _totalCount = 0;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setDateFilter(DateTimeRange? range) {
    _dateFilter = range;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredRecords = _records.where((r) {
      bool matchesSearch = _searchQuery.isEmpty ||
          r.count.toString().contains(_searchQuery);

      bool matchesDate = true;
      if (_dateFilter != null) {
        matchesDate = r.timestamp.isAfter(_dateFilter!.start) &&
            r.timestamp.isBefore(_dateFilter!.end);
      }

      return matchesSearch && matchesDate;
    }).toList();
  }

  Future<String> exportCsv() async {
    final records = _dateFilter != null
        ? await _repo.getByDateRange(_dateFilter!.start, _dateFilter!.end)
        : _records;

    final buffer = StringBuffer();
    buffer.writeln('id,count,timestamp,rssi,battery_pct,battery_mv');
    for (final r in records) {
      buffer.writeln(
        '${r.id},${r.count},${r.timestamp.toIso8601String()},${r.rssi ?? ""},${r.batteryPct ?? ""},${r.batteryMv ?? ""}',
      );
    }
    return buffer.toString();
  }

  Future<int> getTodayCount() => _repo.getTodayCount();
  Future<Map<String, int>> getWeeklyCounts() => _repo.getWeeklyCounts();
  Future<Map<String, int>> getMonthlyCounts() => _repo.getMonthlyCounts();
}