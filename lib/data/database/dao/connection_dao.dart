import 'package:supermini/core/constants/db_constants.dart';
import 'package:supermini/data/models/connection_info.dart';
import 'package:supermini/data/database/app_database.dart';

class ConnectionDao {
  static Future<int> insert(ConnectionInfo info) async {
    final db = await AppDatabase.database;
    return db.insert(DbConstants.connectionTable, info.toMap());
  }

  static Future<int> updateDisconnection(int id, DateTime disconnectedAt, int duration) async {
    final db = await AppDatabase.database;
    return db.update(
      DbConstants.connectionTable,
      {
        DbConstants.columnDisconnectedAt: disconnectedAt.millisecondsSinceEpoch,
        DbConstants.columnDuration: duration,
      },
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  static Future<List<ConnectionInfo>> getHistory({int limit = 20}) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      DbConstants.connectionTable,
      orderBy: '${DbConstants.columnConnectedAt} DESC',
      limit: limit,
    );
    return maps.map((m) => ConnectionInfo.fromMap(m)).toList();
  }

  static Future<int> deleteAll() async {
    final db = await AppDatabase.database;
    return db.delete(DbConstants.connectionTable);
  }
}