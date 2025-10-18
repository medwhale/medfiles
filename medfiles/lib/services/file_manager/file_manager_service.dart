import 'dart:io';
import 'dart:typed_data';

import 'package:medfiles/data/database/app_database.dart';
import 'package:medfiles/services/encryption/encryption_service.dart';
import 'package:medfiles/services/keys/key_manager.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:cryptography/cryptography.dart' show SecretKey;

class FileManagerService {
  FileManagerService({
    EncryptionService? encryptionService,
    KeyManager? keyManager,
    this.rootDirOverride,
  })  : _enc = encryptionService ?? EncryptionService(),
        _keys = keyManager ?? KeyManager();

  static const int maxFileBytes = 100 * 1024 * 1024; // 100 MB
  static const List<String> _dangerousExtensions = <String>[
    '.exe',
    '.bat',
    '.sh',
    '.app',
    '.cmd',
    '.com',
    '.msi',
    '.js',
    '.py',
    '.rb'
  ];

  final EncryptionService _enc;
  final KeyManager _keys;
  final String? rootDirOverride;

  bool isDangerousExtension(String filename) {
    final lower = filename.toLowerCase();
    for (final ext in _dangerousExtensions) {
      if (lower.endsWith(ext)) return true;
    }
    // Double extension like .pdf.exe
    final parts = lower.split('.');
    if (parts.length >= 3) {
      final lastTwo = '.${parts[parts.length - 2]}.${parts.last}';
      for (final ext in _dangerousExtensions) {
        if (lastTwo.endsWith(ext)) return true;
      }
    }
    return false;
  }

  void enforceSizeLimit(int length) {
    if (length > maxFileBytes) {
      throw ArgumentError('File exceeds 100MB limit');
    }
  }

  String _extensionOrEmpty(String name) {
    final ext = p.extension(name);
    return ext; // may be empty
  }

  Future<String> _collectionsRoot() async {
    if (rootDirOverride != null) return p.join(rootDirOverride!, 'collections');
    // Default to databases path sibling directory for internal app storage
    final dbDir =
        await AppDatabaseProvider.instance.dbFactory.getDatabasesPath();
    return p.join(p.dirname(dbDir), 'medfiles_storage', 'collections');
  }

  Future<String> _collectionDir(String collectionId) async {
    final root = await _collectionsRoot();
    return p.join(root, collectionId);
  }

  Future<ImportedFile> importFile({
    required String collectionId,
    required String originalName,
    required Uint8List bytes,
    String? mimeType,
    int? dateEpochMs,
    String? tagsJson,
  }) async {
    enforceSizeLimit(bytes.length);
    if (isDangerousExtension(originalName)) {
      throw ArgumentError('Dangerous file type not allowed');
    }

    final collectionPath = await _collectionDir(collectionId);
    await Directory(collectionPath).create(recursive: true);

    final fileId = const Uuid().v4();
    final obfuscatedName =
        '${const Uuid().v4()}${_extensionOrEmpty(originalName)}';
    final filePath = p.join(collectionPath, obfuscatedName);

    // Per-file key and encryption
    final fileKey = await _enc.generateRandomFileKey();
    final sealed = await _enc.encryptBytes(plaintext: bytes, key: fileKey);

    // Persist encrypted file to disk
    final outFile = File(filePath);
    await outFile.writeAsBytes(sealed, flush: true);

    // Wrap file key with master DEK
    final dekBytes = await _keys.getOrCreateMasterDek();
    final wrappedKey = await _enc.wrapFileKey(
      fileKey: fileKey,
      masterKey: SecretKey(dekBytes),
    );

    // Insert metadata into DB
    final now = DateTime.now().millisecondsSinceEpoch;
    final db = AppDatabaseProvider.instance.db;
    await db.insert(
      'files',
      <String, Object?>{
        'id': fileId,
        'collection_id': collectionId,
        'display_name': originalName,
        'obfuscated_name': obfuscatedName,
        'mime_type': mimeType,
        'size': bytes.length,
        'date': dateEpochMs,
        'tags': tagsJson,
        'created_at': now,
        'updated_at': now,
      },
    );
    await db.insert(
      'file_keys',
      <String, Object?>{
        'file_id': fileId,
        'wrapped_key': wrappedKey,
      },
    );

    return ImportedFile(
      fileId: fileId,
      obfuscatedPath: filePath,
      size: sealed.length,
    );
  }

  Future<Uint8List> readDecryptedFile(String fileId) async {
    final db = AppDatabaseProvider.instance.db;
    final files =
        await db.query('files', where: 'id = ?', whereArgs: <Object?>[fileId]);
    if (files.isEmpty) throw StateError('File not found');
    final fileRow = files.first;
    final keys = await db
        .query('file_keys', where: 'file_id = ?', whereArgs: <Object?>[fileId]);
    if (keys.isEmpty) throw StateError('File key not found');
    final wrapped = keys.first['wrapped_key'] as Uint8List;
    final dekBytes = await _keys.getOrCreateMasterDek();
    final fileKey = await _enc.unwrapFileKey(
      wrapped: wrapped,
      masterKey: SecretKey(dekBytes),
      nonceLength: 12,
    );
    final collectionPath =
        await _collectionDir(fileRow['collection_id'] as String);
    final filePath =
        p.join(collectionPath, fileRow['obfuscated_name'] as String);
    final sealed = await File(filePath).readAsBytes();
    return _enc.decryptBytes(sealed: sealed, key: fileKey, nonceLength: 12);
  }
}

class ImportedFile {
  ImportedFile(
      {required this.fileId, required this.obfuscatedPath, required this.size});
  final String fileId;
  final String obfuscatedPath;
  final int size;
}
