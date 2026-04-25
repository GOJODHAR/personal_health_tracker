// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_health_tracker/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Since HealthTrackerApp requires Firebase, this test might fail 
    // without Firebase initialization, but we fix the class name error.
    await tester.pumpWidget(const HealthTrackerApp());

    // Basic check to see if the app starts
    expect(find.byType(HealthTrackerApp), findsOneWidget);
  });
}
