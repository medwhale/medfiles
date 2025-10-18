import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medfiles/data/database/app_database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SQLCipher opens and closes database with password',
      (tester) async {
    WidgetsFlutterBinding.ensureInitialized();

    final dek = Uint8List(32);
    for (var i = 0; i < dek.length; i++) {
      dek[i] = (i * 7) & 0xff;
    }

    final db = await AppDatabaseProvider.instance.openWithDek(dek);
    expect(db.isOpen, isTrue);

    await AppDatabaseProvider.instance.close();
  });
}
