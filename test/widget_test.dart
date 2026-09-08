import 'package:flutter_test/flutter_test.dart';

import 'package:kivil_app/main.dart';

void main() {
  testWidgets('Welcome screen shows the primary CTA', (WidgetTester tester) async {
    await tester.pumpWidget(const KivilApp());

    expect(find.text('Hemen Başla'), findsOneWidget);
  });
}
