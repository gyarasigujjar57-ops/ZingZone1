import 'package:flutter_test/flutter_test.dart';
import 'package:zing_zone/main.dart';

void main() {
  testWidgets('Zing Zone opens the four redesigned tabs', (tester) async {
    await tester.pumpWidget(const ZingZone());
    expect(find.text('ZING ZONE'), findsOneWidget);
    expect(find.text('Explore app as guest'), findsOneWidget);
    await tester.tap(find.text('Explore app as guest'));
    await tester.pumpAndSettle();
    expect(find.text('AI Chat'), findsOneWidget);
    expect(find.text('Store'), findsOneWidget);
    expect(find.text('Rewards'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
