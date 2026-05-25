import 'package:supermini/core/constants/db_constants.dart';
import 'package:supermini/data/models/mail_record.dart';
import 'package:supermini/data/database/app_database.dart';

class MailDao {
  static Future<List<MailRecord>> getAll({int limit = 100, int offset = 0}) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      DbConstants.mailTable,
      orderBy: '${DbConstants.columnTimestamp} DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => MailRecord.fromMap(m)).toList();
  }

  static Future<int> insert(MailRecord record) async {
    final db = await AppDatabase.database;
    return db.insert(DbConstants.mailTable, record.toMap());
  }

  static Future<int> delete(int id) async {
    final db = await AppDatabase.database;
    return db.delete(
      DbConstants.mailTable,
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteAll() async {
    final db = await AppDatabase.database;
    return db.delete(DbConstants.mailTable);
  }

  static Future<List<MailRecord>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      DbConstants.mailTable,
      where:
          '${DbConstants.columnTimestamp} >= ? AND ${DbConstants.columnTimestamp} <= ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: '${DbConstants.columnTimestamp} DESC',
    );
    return maps.map((m) => MailRecord.fromMap(m)).toList();
  }

  static Future<List<MailRecord>> search(String query) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      DbConstants.mailTable,
      where: '${DbConstants.columnCount} LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: '${DbConstants.columnTimestamp} DESC',
    );
    return maps.map((m) => MailRecord.fromMap(m)).toList();
  }

  static Future<int> getTotalCount() async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DbConstants.mailTable}',
    );
    return result.first['count'] as int? ?? 0;
  }

  static Future<int> getTodayCount() async {
    final db = await AppDatabase.database;
    final startOfDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).millisecondsSinceEpoch;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DbConstants.mailTable} WHERE ${DbConstants.columnTimestamp} >= ?',
      [startOfDay],
    );
    return result.first['count'] as int? ?? 0;
  }

  static Future<Map<String, int>> getWeeklyCounts() async {
    final db = await AppDatabase.database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
        .millisecondsSinceEpoch;

    final result = await db.rawQuery(
      '''SELECT date(${DbConstants.columnTimestamp} / 1000, 'unixepoch') as day, 
         COUNT(*) as count FROM ${DbConstants.mailTable} 
         WHERE ${DbConstants.columnTimestamp} >= ? GROUP BY day ORDER BY day''',
      [start],
    );

    final Map<String, int> counts = {};
    for (final row in result) {
      counts[row['day'] as String] = row['count'] as int;
    }
    return counts;
  }

  static Future<Map<String, int>> getMonthlyCounts() async {
    final db = await AppDatabase.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;

    final result = await db.rawQuery(
      '''SELECT date(${DbConstants.columnTimestamp} / 1000, 'unixepoch') as day, 
         COUNT(*) as count FROM ${DbConstants.mailTable} 
         WHERE ${DbConstants.columnTimestamp} >= ? GROUP BY day ORDER BY day''',
      [startOfMonth],
    );

    final Map<String, int> counts = {};
    for (final row in result) {
      counts[row['day'] as String] = row['count'] as int;
    }
    return counts;
  }

  static Future<MailRecord?> getLatest() async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      DbConstants.mailTable,
      orderBy: '${DbConstants.columnTimestamp} DESC',
      limit: 1,
    );
    return maps.isNotEmpty ? MailRecord.fromMap(maps.first) : null;
  }
}