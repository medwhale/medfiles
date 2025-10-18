import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:medfiles/data/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AppDatabaseProvider (unit)', () {
    test('passwordFromDek returns base64 string', () {
      final dek = Uint8List.fromList([0, 1, 2, 3]);
      final pw = AppDatabaseProvider.passwordFromDek(dek);
      expect(pw, 'AAECAw==');
    });

    test('database initially not open', () {
      expect(AppDatabaseProvider.instance.isOpen, isFalse);
    });
  });
}
