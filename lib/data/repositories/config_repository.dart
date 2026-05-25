import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:supermini/core/constants/db_constants.dart';
import '../database/app_database.dart';
import '../models/device_config.dart';

class ConfigRepository {
  Future<DeviceConfig> getConfig() async {
    final db = await AppDatabase.database;
    final maps = await db.query(DbConstants.configTable);
    final Map<String, dynamic> configMap = {};
    for (final m in maps) {
      final key = m[DbConstants.columnKey] as String;
      final value = m[DbConstants.columnValue] as String;
      configMap[key] = int.tryParse(value) ?? value;
    }
    return DeviceConfig.fromJson(configMap);
  }

  Future<void> saveConfig(DeviceConfig config) async {
    final db = await AppDatabase.database;
    final json = config.toJson();
    for (final entry in json.entries) {
      await db.insert(
        DbConstants.configTable,
        {
          DbConstants.columnKey: entry.key,
          DbConstants.columnValue: entry.value.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> updateFromJson(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final config = DeviceConfig.fromJson(json);
      await saveConfig(config);
    } catch (_) {}
  }

  Future<void> clear() async {
    final db = await AppDatabase.database;
    await db.delete(DbConstants.configTable);
  }
}