// Basic Flutter widget test for Secure Vault

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    // Build a simple widget to verify the test framework works
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Secure Vault'),
          ),
        ),
      ),
    );

    // Verify that the text appears
    expect(find.text('Secure Vault'), findsOneWidget);
  });
}
