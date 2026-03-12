import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumobee/screens/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen shows remaining credits', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DashboardScreen(remainingCredits: 3, totalCredits: 10),
    ));

    expect(find.text('剩餘額度: 3 / 10'), findsOneWidget);
    expect(find.text('如何使用'), findsOneWidget);
  });
}
