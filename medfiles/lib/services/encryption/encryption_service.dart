import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class EncryptionService {
  EncryptionService({AesGcm? aesGcm, Pbkdf2? pbkdf2})
      : _aesGcm = aesGcm ?? AesGcm.with256bits(),
        _pbkdf2 = pbkdf2 ??
            Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 100000, bits: 256);

  final AesGcm _aesGcm;
  final Pbkdf2 _pbkdf2;

  Future<SecretKey> generateRandomFileKey() async {
    final algorithm = AesGcm.with256bits();
    final key = await algorithm.newSecretKey();
    return key;
  }

  Future<SecretKey> deriveKeyFromPin({
    required String pin,
    required List<int> salt,
  }) async {
    final secretKey = await _pbkdf2.deriveKey(
      secretKey: SecretKey(pin.codeUnits),
      nonce: salt,
    );
    return secretKey;
  }

  Future<Uint8List> encryptBytes({
    required List<int> plaintext,
    required SecretKey key,
    List<int>? nonce,
    List<int>? associatedData,
  }) async {
    final usedNonce = nonce ?? _aesGcm.newNonce();
    final secretBox = await _aesGcm.encrypt(
      plaintext,
      secretKey: key,
      nonce: usedNonce,
      aad: associatedData ?? const <int>[],
    );
    // Concatenate: nonce | ciphertext | mac
    final out = Uint8List(
      usedNonce.length +
          secretBox.cipherText.length +
          secretBox.mac.bytes.length,
    )
      ..setRange(0, usedNonce.length, usedNonce)
      ..setRange(
        usedNonce.length,
        usedNonce.length + secretBox.cipherText.length,
        secretBox.cipherText,
      )
      ..setRange(
        usedNonce.length + secretBox.cipherText.length,
        usedNonce.length +
            secretBox.cipherText.length +
            secretBox.mac.bytes.length,
        secretBox.mac.bytes,
      );
    return out;
  }

  Future<Uint8List> decryptBytes({
    required List<int> sealed,
    required SecretKey key,
    required int nonceLength,
    List<int>? associatedData,
  }) async {
    final macLength = 16; // AES-GCM tag length (128-bit)
    if (sealed.length < nonceLength + macLength) {
      throw ArgumentError('Sealed data too short');
    }
    final nonce = sealed.sublist(0, nonceLength);
    final macStart = sealed.length - macLength;
    final cipherText = sealed.sublist(nonceLength, macStart);
    final mac = Mac(sealed.sublist(macStart));
    final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);
    final clear = await _aesGcm.decrypt(
      secretBox,
      secretKey: key,
      aad: associatedData ?? const <int>[],
    );
    return Uint8List.fromList(clear);
  }

  Future<Uint8List> wrapFileKey({
    required SecretKey fileKey,
    required SecretKey masterKey,
    List<int>? associatedData,
  }) async {
    final fileKeyBytes = await fileKey.extractBytes();
    return encryptBytes(
      plaintext: fileKeyBytes,
      key: masterKey,
      associatedData: associatedData,
    );
  }

  Future<SecretKey> unwrapFileKey({
    required List<int> wrapped,
    required SecretKey masterKey,
    required int nonceLength,
    List<int>? associatedData,
  }) async {
    final fileKeyBytes = await decryptBytes(
      sealed: wrapped,
      key: masterKey,
      nonceLength: nonceLength,
      associatedData: associatedData,
    );
    return SecretKey(fileKeyBytes);
  }
}
