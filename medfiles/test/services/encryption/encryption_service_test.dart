import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:medfiles/services/encryption/encryption_service.dart';

void main() {
  group('EncryptionService', () {
    late EncryptionService service;

    setUp(() {
      service = EncryptionService();
    });

    test('deriveKeyFromPin produces same key for same pin+salt', () async {
      const pin = '123456';
      final salt = Uint8List.fromList(List<int>.generate(16, (i) => i));
      final k1 = await service.deriveKeyFromPin(pin: pin, salt: salt);
      final k2 = await service.deriveKeyFromPin(pin: pin, salt: salt);
      expect(await k1.extractBytes(), await k2.extractBytes());
    });

    test('encrypt/decrypt round trip', () async {
      final key = await service.generateRandomFileKey();
      final message = Uint8List.fromList(
        List<int>.generate(1024, (i) => i % 251),
      );
      final sealed = await service.encryptBytes(plaintext: message, key: key);
      final clear = await service.decryptBytes(
        sealed: sealed,
        key: key,
        nonceLength: 12,
      );
      expect(clear, message);
    });

    test('wrap/unwrap file key', () async {
      final master = await service.generateRandomFileKey();
      final fileKey = await service.generateRandomFileKey();
      final wrapped = await service.wrapFileKey(
        fileKey: fileKey,
        masterKey: master,
      );
      final unwrapped = await service.unwrapFileKey(
        wrapped: wrapped,
        masterKey: master,
        nonceLength: 12,
      );
      expect(await unwrapped.extractBytes(), await fileKey.extractBytes());
    });
  });
}
