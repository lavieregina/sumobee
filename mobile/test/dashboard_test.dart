import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumobee/screens/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DashboardScreen(),
    ));

    // Verify the screen renders
    expect(find.byType(DashboardScreen), findsOneWidget);
  });
}
