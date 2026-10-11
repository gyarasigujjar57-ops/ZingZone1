import 'package:flutter_test/flutter_test.dart';
import 'package:zing_zone/main.dart';

void main() {
  testWidgets('Zing Zone opens its four primary navigation tabs', (tester) async {
    await tester.pumpWidget(const ZingZone());
    expect(find.text('ZING ZONE'), findsOneWidget);
    expect(find.text('Explore app'), findsOneWidget);

    await tester.tap(find.text('Explore app'));
    await tester.pumpAndSettle();

    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Store'), findsOneWidget);
    expect(find.text('Rewards'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
