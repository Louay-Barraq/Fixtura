import 'package:flutter_test/flutter_test.dart';
import 'package:elboutoula/main.dart';

void main() {
  testWidgets('App smoke test - verifies dashboard title loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ElBoutoulaApp());

    // Verify that the dashboard header is present.
    expect(find.text('EL BOUTOULA'), findsOneWidget);
  });
}
