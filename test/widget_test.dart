import 'package:flutter_test/flutter_test.dart';
import 'package:fixtura/main.dart';

void main() {
  testWidgets('App smoke test - verifies dashboard title loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FixturaApp());

    // Verify that the dashboard header is present.
    expect(find.text('FIXTURA'), findsOneWidget);
  });
}
