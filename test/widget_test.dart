import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zing_zone/main.dart';

void main() {
  testWidgets('Welcome screen offers supported account sign-in methods', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: Welcome()));
    expect(find.text('ZING ZONE'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with mobile'), findsOneWidget);
    expect(find.text('Explore app as guest'), findsNothing);
  });
}
