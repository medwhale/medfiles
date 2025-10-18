import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:medfiles/data/database/app_database.dart';

class _FfiFactory implements AppDatabaseFactory {
  final DatabaseFactory _factory;
  _FfiFactory(this._factory);

  @override
  Future<String> getDatabasesPath() async => _factory.getDatabasesPath();

  @override
  Future<dynamic> openDatabase(
    String path, {
    String? password,
    int? version,
    Future<void> Function(dynamic db)? onConfigure,
    Future<void> Function(dynamic db, int version)? onCreate,
  }) async {
    // sqflite_common_ffi does not support SQLCipher passwords; open normally
    final db = await _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: version,
        onConfigure: onConfigure,
        onCreate: onCreate,
      ),
    );
    return db;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('AppDatabaseProvider (FFI unit)', () {
    late Directory tempDir;
    late _FfiFactory ffiFactory;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('medfiles_test_');
      databaseFactory = databaseFactoryFfi;
      // Ensure FFI factory uses the temporary path
      await databaseFactory.setDatabasesPath(tempDir.path);
      ffiFactory = _FfiFactory(databaseFactory);
      AppDatabaseProvider.instance.dbFactory = ffiFactory;
    });

    tearDown(() async {
      await AppDatabaseProvider.instance.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('openWithDek creates and opens database (FFI)', () async {
      final dek = Uint8List(32);
      for (var i = 0; i < dek.length; i++) {
        dek[i] = (i * 11) & 0xff;
      }
      final db = await AppDatabaseProvider.instance.openWithDek(dek);
      expect(db.isOpen, isTrue);
    });
  });
}
