import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uniguide_cambodia/main.dart';

void main() {
  testWidgets('Basic app load test', (WidgetTester tester) async {
    await tester.pumpWidget(const UniGuideApp());

    // Since your app starts with onboarding screen,
    // we just check if MaterialApp loads correctly
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}