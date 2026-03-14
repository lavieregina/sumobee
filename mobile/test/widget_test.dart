// Basic Flutter widget test — verifies the app widget can be instantiated.

import 'package:flutter_test/flutter_test.dart';

import 'package:sumobee/main.dart';

void main() {
  test('SumoBeeApp can be instantiated', () {
    // Verify the app widget class exists and can be constructed
    const app = SumoBeeApp();
    expect(app, isNotNull);
  });
}
