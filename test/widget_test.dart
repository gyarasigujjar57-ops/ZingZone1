import 'package:flutter_test/flutter_test.dart';
import 'package:zing_zone/main.dart';

void main() {
  testWidgets('Zing Zone shows its four primary navigation tabs', (tester) async {
    await tester.pumpWidget(const ZingZoneApp());
    expect(find.text('ZING ZONE'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Store'), findsOneWidget);
    expect(find.text('Rewards'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
