import 'dart:convert';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;

abstract class AppDatabaseFactory {
  Future<String> getDatabasesPath();
  Future<dynamic> openDatabase(
    String path, {
    String? password,
    int? version,
    Future<void> Function(dynamic db)? onConfigure,
    Future<void> Function(dynamic db, int version)? onCreate,
  });
}

class _SqlCipherFactory implements AppDatabaseFactory {
  @override
  Future<String> getDatabasesPath() => sqlcipher.getDatabasesPath();

  @override
  Future<dynamic> openDatabase(
    String path, {
    String? password,
    int? version,
    Future<void> Function(dynamic db)? onConfigure,
    Future<void> Function(dynamic db, int version)? onCreate,
  }) {
    return sqlcipher.openDatabase(
      path,
      password: password,
      version: version,
      onConfigure: onConfigure,
      onCreate: onCreate,
    );
  }
}

class AppDatabaseProvider {
  AppDatabaseProvider._();
  static final AppDatabaseProvider instance = AppDatabaseProvider._();

  dynamic _db;
  // Allow tests to inject FFI factory
  AppDatabaseFactory dbFactory = _SqlCipherFactory();

  bool get isOpen => _db != null;

  static String passwordFromDek(Uint8List dekBytes) {
    // Use base64 string of DEK as SQLCipher password (consistent across opens)
    return base64Encode(dekBytes);
  }

  Future<dynamic> openWithDek(
    Uint8List dekBytes, {
    String? overrideDbDir,
  }) async {
    if (_db != null) return _db!;
    final dbDir = overrideDbDir ?? await dbFactory.getDatabasesPath();
    final dbPath = p.join(dbDir, 'medfiles.db');
    final password = passwordFromDek(dekBytes);
    _db = await dbFactory.openDatabase(
      dbPath,
      password: password,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, int version) async {
        // Users table (reserved for future app-level settings)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          );
        ''');

        // Collections table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS collections (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER
          );
        ''');

        // Files table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS files (
            id TEXT PRIMARY KEY,
            collection_id TEXT NOT NULL,
            display_name TEXT NOT NULL,
            obfuscated_name TEXT NOT NULL,
            mime_type TEXT,
            size INTEGER,
            date INTEGER,
            tags TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER,
            FOREIGN KEY(collection_id) REFERENCES collections(id) ON DELETE CASCADE
          );
        ''');

        // File keys table (wrapped per-file keys)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS file_keys (
            file_id TEXT PRIMARY KEY,
            wrapped_key BLOB NOT NULL,
            FOREIGN KEY(file_id) REFERENCES files(id) ON DELETE CASCADE
          );
        ''');
      },
    );
    return _db!;
  }

  dynamic get db {
    final database = _db;
    if (database == null) {
      throw StateError('Database not opened');
    }
    return database;
  }

  Future<void> close() async {
    final database = _db;
    if (database != null) {
      await database.close();
      _db = null;
    }
  }
}
