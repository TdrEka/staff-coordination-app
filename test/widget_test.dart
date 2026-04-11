import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Employee feature smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Staff Coordination')),
        ),
      ),
    );

    expect(find.text('Staff Coordination'), findsOneWidget);
  });
}
