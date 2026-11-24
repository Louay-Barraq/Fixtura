import 'dart:io';

import 'package:fixtura/l10n/app_localizations.dart';
import 'package:fixtura/models/match.dart';
import 'package:fixtura/models/tournament.dart';
import 'package:fixtura/providers/tournament_provider.dart';
import 'package:fixtura/widgets/score_entry_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late TournamentProvider provider;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // Test files run in parallel, so each one needs its own database.
    final dir = await Directory.systemTemp.createTemp('fixtura_test');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  MatchModel match(int round, int pos) => provider.activeMatches
      .firstWhere((m) => m.roundNumber == round && m.bracketPos == pos);

  Future<void> playedBracket() async {
    provider = TournamentProvider();
    await provider.clearAllTournaments();
    final id = await provider.createTournament(
      name: 'Tournoi l houma',
      type: TournamentType.knockout,
      legs: 1,
      teamNames: List.generate(8, (i) => 'P${i + 1}'),
    );
    await provider.loadTournamentDetails(id!);
    for (var pos = 0; pos < 4; pos++) {
      await provider.updateMatchScore(match(1, pos).id!, 2, 0);
    }
    await provider.updateMatchScore(match(2, 0).id!, 2, 0);
  }

  group('laterMatchClearedBy', () {
    setUp(playedBracket);

    test('names the next match when the winner changes', () {
      expect(provider.laterMatchClearedBy(match(1, 0), 0, 2)?.id, match(2, 0).id);
    });

    test('is null when the winner stays the same', () {
      expect(provider.laterMatchClearedBy(match(1, 0), 3, 1), isNull);
    });

    test('is null when the next match has no result yet', () {
      expect(provider.laterMatchClearedBy(match(1, 2), 0, 2), isNull);
    });

    test('names the next match when a result is reset', () {
      expect(provider.laterMatchClearedBy(match(1, 0), null, null)?.id, match(2, 0).id);
    });
  });

  group('score dialog', () {
    Future<void> openDialog(WidgetTester tester, {int round = 1, int pos = 0}) async {
      final teams = provider.activeTeams;
      final m = match(round, pos);
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ScoreEntryDialog(
              match: m,
              homeTeam: teams.firstWhere((t) => t.id == m.homeTeamId),
              awayTeam: teams.firstWhere((t) => t.id == m.awayTeamId),
              tournamentType: TournamentType.knockout,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('cancelling the warning keeps every result', (tester) async {
      await tester.runAsync(playedBracket);
      await openDialog(tester);

      await tester.tap(find.text('RESET SCORE'));
      await tester.pumpAndSettle();
      expect(find.text('CLEAR LATER RESULT?'), findsOneWidget);
      expect(find.textContaining('Semi-finals'), findsOneWidget);

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
      expect(find.text('CLEAR LATER RESULT?'), findsNothing);
      expect(match(1, 0).isPlayed, isTrue);
      expect(match(2, 0).isPlayed, isTrue);
    });

    testWidgets('continuing the warning clears the later result', (tester) async {
      await tester.runAsync(playedBracket);
      await openDialog(tester);

      await tester.tap(find.text('RESET SCORE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      // The save runs against a real database, so let it finish between frames.
      for (var i = 0; i < 20 && match(2, 0).isPlayed; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
      }

      expect(match(1, 0).isPlayed, isFalse);
      expect(match(2, 0).isPlayed, isFalse);
    });

    testWidgets('saving a knockout draw without a penalty winner explains why inside the sheet', (tester) async {
      await tester.runAsync(playedBracket);
      await openDialog(tester, round: 2, pos: 1); // second semi: both players known, no result

      const warning = "A draw isn't allowed in a knockout match. Pick the penalty shootout winner.";
      expect(find.text(warning), findsNothing);

      await tester.tap(find.text('SAVE RESULT'));
      await tester.pumpAndSettle();
      expect(find.text(warning), findsOneWidget);
      expect(match(2, 1).isPlayed, isFalse);

      // Picking a winner clears the warning
      final finalMatch = match(2, 1);
      final homeName = provider.activeTeams.firstWhere((t) => t.id == finalMatch.homeTeamId).name;
      await tester.tap(find.text(homeName).last);
      await tester.pumpAndSettle();
      expect(find.text(warning), findsNothing);
    });
  });
}
