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
    expect(find.text('Continue as Guest — no signup'), findsOneWidget);
    await tester.ensureVisible(find.text('Continue as Guest — no signup'));
    await tester.tap(find.text('Continue as Guest — no signup'));
    await tester.pumpAndSettle();

    // Assert the actual tab page widgets instead of relying on navigation
    // label rendering, which can vary with Flutter's label behavior.
    expect(find.byType(ChatPage, skipOffstage: false), findsOneWidget);
    expect(find.byType(StorePage, skipOffstage: false), findsOneWidget);
    expect(find.byType(RewardsPage, skipOffstage: false), findsOneWidget);
    expect(find.byType(ProfilePage, skipOffstage: false), findsOneWidget);
  });
}
