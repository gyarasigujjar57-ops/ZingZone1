import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:zing_zone/main.dart';

void main() {
  testWidgets('Zing Zone opens the four redesigned tabs', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ZingZone());
    expect(find.text('ZING ZONE'), findsOneWidget);
    expect(find.text('Explore app as guest'), findsOneWidget);
    await tester.ensureVisible(find.text('Explore app as guest'));
    await tester.tap(find.text('Explore app as guest'));
    await tester.pumpAndSettle();
    expect(find.text('AI Chat'), findsOneWidget);
    expect(find.text('Store'), findsOneWidget);
    expect(find.text('Rewards'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
