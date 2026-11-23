import 'package:fixtura/l10n/app_localizations.dart';
import 'package:fixtura/providers/tournament_provider.dart';
import 'package:fixtura/screens/create_tournament_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// The test font is much wider than the real ones, so text overflows that do
// not happen on a device are ignored; anything else fails the test.
void expectNoErrorsBesidesOverflow(WidgetTester tester) {
  final error = tester.takeException();
  expect(error == null || error.toString().contains('overflowed'), isTrue, reason: '$error');
}

void main() {
  testWidgets('switching between formats shows the right settings without errors', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TournamentProvider(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CreateTournamentScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The group dropdowns are inserted above the legs dropdown; they must not
    // inherit its selected value.
    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();
    expectNoErrorsBesidesOverflow(tester);
    expect(find.text('GROUP STAGE SETTINGS'), findsOneWidget);
    expect(find.text('1 LEG (SINGLE)'), findsOneWidget);

    await tester.tap(find.text('League'));
    await tester.pumpAndSettle();
    expectNoErrorsBesidesOverflow(tester);
    expect(find.text('GROUP STAGE SETTINGS'), findsNothing);
  });
}
