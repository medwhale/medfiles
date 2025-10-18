import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:medfiles/data/database/app_database.dart';
import 'package:medfiles/services/encryption/encryption_service.dart';
import 'package:medfiles/services/file_manager/file_manager_service.dart';
import 'package:medfiles/services/keys/key_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

class _FakeKeyManager implements KeyManager {
  _FakeKeyManager(this._dek);
  final Uint8List _dek;

  @override
  Future<Uint8List> getOrCreateMasterDek() async => _dek;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('FileManagerService', () {
    late Directory tempDir;
    late FileManagerService svc;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('medfiles_fm_test_');
      AppDatabaseProvider.instance.dbFactory = _FfiFactory(databaseFactoryFfi);
      // Open DB with any 32-byte dek (ignored by FFI)
      final dek = Uint8List.fromList(List<int>.generate(32, (i) => i));
      await AppDatabaseProvider.instance.openWithDek(
        dek,
        overrideDbDir: tempDir.path,
      );

      svc = FileManagerService(
        encryptionService: EncryptionService(),
        keyManager: _FakeKeyManager(dek),
        rootDirOverride: tempDir.path,
      );
    });

    tearDown(() async {
      await AppDatabaseProvider.instance.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('dangerous extension detection', () {
      expect(svc.isDangerousExtension('evil.exe'), isTrue);
      expect(svc.isDangerousExtension('note.pdf.exe'), isTrue);
      expect(svc.isDangerousExtension('report.pdf'), isFalse);
    });

    test('size limit enforcement', () {
      expect(() => svc.enforceSizeLimit(100 * 1024 * 1024 + 1),
          throwsArgumentError);
      expect(() => svc.enforceSizeLimit(1024), returnsNormally);
    });

    test('import -> decrypt round trip', () async {
      final original =
          Uint8List.fromList(List<int>.generate(4096, (i) => (i * 13) & 0xff));
      // Ensure referenced collection exists to satisfy foreign key constraint
      final db = AppDatabaseProvider.instance.db;
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('collections', <String, Object?>{
        'id': 'col-123',
        'name': 'Test Collection',
        'created_at': now,
        'updated_at': now,
        'deleted_at': null,
      });
      final imported = await svc.importFile(
        collectionId: 'col-123',
        originalName: 'scan.pdf',
        bytes: original,
        mimeType: 'application/pdf',
      );
      expect(File(imported.obfuscatedPath).existsSync(), isTrue);
      final roundtrip = await svc.readDecryptedFile(imported.fileId);
      expect(roundtrip, original);
    });
  });
}
