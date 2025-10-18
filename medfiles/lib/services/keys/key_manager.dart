import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyManager {
  KeyManager({FlutterSecureStorage? storage, AesGcm? aes})
      : _storage = storage ?? const FlutterSecureStorage(),
        _aes = aes ?? AesGcm.with256bits();

  static const String _dekStorageKey = 'medfiles_master_dek_v1';

  final FlutterSecureStorage _storage;
  final AesGcm _aes;

  Future<Uint8List> getOrCreateMasterDek() async {
    final existing = await _storage.read(key: _dekStorageKey);
    if (existing != null && existing.isNotEmpty) {
      return Uint8List.fromList(base64Decode(existing));
    }
    final secretKey = await _aes.newSecretKey();
    final bytes = await secretKey.extractBytes();
    await _storage.write(key: _dekStorageKey, value: base64Encode(bytes));
    return Uint8List.fromList(bytes);
  }
}
