import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:supermini/core/constants/db_constants.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    try {
      _database ??= await _initDatabase().timeout(const Duration(seconds: 5));
      return _database!;
    } catch (e) {
      debugPrint('Database initialization error: $e');
      rethrow;
    }
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, DbConstants.dbName);
    debugPrint('Initializing database at: $path');

    return openDatabase(
      path,
      version: DbConstants.dbVersion,
      onCreate: (db, version) async {
        debugPrint('Creating database tables...');
        await _onCreate(db, version);
      },
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.mailTable} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnCount} INTEGER NOT NULL,
        ${DbConstants.columnTimestamp} INTEGER NOT NULL,
        ${DbConstants.columnRssi} INTEGER,
        ${DbConstants.columnBattery} INTEGER,
        ${DbConstants.columnBatteryMv} INTEGER
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_mail_timestamp ON ${DbConstants.mailTable} (${DbConstants.columnTimestamp})
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.configTable} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnKey} TEXT NOT NULL UNIQUE,
        ${DbConstants.columnValue} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.connectionTable} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnDeviceId} TEXT,
        ${DbConstants.columnDeviceName} TEXT,
        ${DbConstants.columnConnectedAt} INTEGER NOT NULL,
        ${DbConstants.columnDisconnectedAt} INTEGER,
        ${DbConstants.columnRssi} INTEGER,
        ${DbConstants.columnMtu} INTEGER,
        ${DbConstants.columnDuration} INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.statsTable} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnDate} TEXT NOT NULL UNIQUE,
        ${DbConstants.columnTotalMail} INTEGER NOT NULL DEFAULT 0,
        ${DbConstants.columnBatteryMv} INTEGER,
        ${DbConstants.columnRssi} INTEGER
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      debugPrint('Migrating database from version $oldVersion to $newVersion');
      try {
        await db.execute(
            'ALTER TABLE ${DbConstants.connectionTable} ADD COLUMN ${DbConstants.columnDeviceId} TEXT');
        await db.execute(
            'ALTER TABLE ${DbConstants.connectionTable} ADD COLUMN ${DbConstants.columnDeviceName} TEXT');
        await db.execute(
            'ALTER TABLE ${DbConstants.connectionTable} ADD COLUMN ${DbConstants.columnMtu} INTEGER');
      } catch (e) {
        debugPrint('Migration error: $e');
      }
    }
  }

  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  static Future<void> reset() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, DbConstants.dbName);
    await close();
    await deleteDatabase(path);
    _database = null;
  }
}