// Basic Flutter widget test for Secure Vault

import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SecureVaultApp());

    // Verify that the app title appears
    expect(find.text('Secure Vault'), findsWidgets);
  });
}
