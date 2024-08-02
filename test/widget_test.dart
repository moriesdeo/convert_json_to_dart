// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:convert_json_to_class_dart/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('Counter App', () {
    testWidgets('Counter increments smoke test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify that our counter has incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Counter decrements smoke test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Increment the counter first.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify counter incremented to 1.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsNothing);

      // Tap the '-' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      // Verify that our counter has decremented.
      expect(find.text('1'), findsNothing);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Counter does not decrement below zero', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);

      // Tap the '-' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      // Verify that our counter is still 0.
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('All buttons and widgets are present', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that all widgets are present.
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('Display correct title', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that the title is displayed correctly.
      expect(find.text('JSON to Dart Converter'), findsOneWidget);
    });
  });
}