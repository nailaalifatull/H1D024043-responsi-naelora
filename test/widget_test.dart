import 'package:flutter_test/flutter_test.dart';
import 'package:naelora/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NaeloraApp());
    expect(find.byType(NaeloraApp), findsOneWidget);
  });
}
