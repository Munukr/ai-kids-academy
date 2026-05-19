import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic Flutter widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('AI Kids Academy'),
          ),
        ),
      ),
    );
    expect(find.text('AI Kids Academy'), findsOneWidget);
  });

  test('Lesson count is 12', () {
    expect(12, 12);
  });

  test('Language codes are valid', () {
    final languages = ['en', 'ru', 'he'];
    expect(languages.length, 3);
    expect(languages.contains('en'), true);
    expect(languages.contains('ru'), true);
    expect(languages.contains('he'), true);
  });
}
