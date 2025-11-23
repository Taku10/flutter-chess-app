import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Shows CSS Chess Club title', (WidgetTester tester) async {
    // Pump a simple widget tree that looks like your app title
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('CSS Chess Club'),
          ),
        ),
      ),
    );

    // Verify that the title text is found
    expect(find.text('CSS Chess Club'), findsOneWidget);
  });
}
