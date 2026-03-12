import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumobee/screens/preview_screen.dart';

void main() {
  testWidgets('PreviewScreen renders markdown content', (WidgetTester tester) async {
    const markdown = '# Test Title\n## Key Takeaways\n- Point 1';
    
    await tester.pumpWidget(const MaterialApp(
      home: PreviewScreen(content: markdown, taskId: 'test-id'),
    ));

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Key Takeaways'), findsOneWidget);
  });
}
