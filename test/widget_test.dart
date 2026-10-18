import 'package:flutter_test/flutter_test.dart';

import 'package:gym_zero/main.dart';

void main() {
  testWidgets('renders the gym dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Live gym performance and follow-ups'), findsOneWidget);
    expect(find.text('Total Members'), findsOneWidget);
    expect(find.text('Membership revenue trend'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
