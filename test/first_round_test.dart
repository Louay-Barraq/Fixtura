import 'dart:io';

import 'package:fixtura/l10n/app_localizations.dart';
import 'package:fixtura/logic/tournament_rules.dart';
import 'package:fixtura/models/match.dart';
import 'package:fixtura/models/tournament.dart';
import 'package:fixtura/providers/tournament_provider.dart';
import 'package:fixtura/screens/tournament_details_screen.dart';
import 'package:fixtura/widgets/custom_match_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  MatchModel m(int round, {bool played = false, bool bye = false}) => MatchModel(
        tournamentId: 1,
        homeTeamId: 1,
        awayTeamId: bye ? null : 2,
        isPlayed: played,
        roundNumber: round,
        roundName: 'Round $round',
      );

  group('defaultRound', () {
    test('opens on the first round with a match left to play', () {
      expect(defaultRound([m(1, played: true), m(2), m(3)]), 2);
    });

    test('skips rounds that only hold BYEs or TBD matches', () {
      expect(defaultRound([m(1, bye: true), m(2)]), 2);
    });

    test('a finished tournament opens on its last round', () {
      expect(defaultRound([m(1, played: true), m(2, played: true)]), 2);
    });

    test('a new tournament opens on round 1', () {
      expect(defaultRound([m(1), m(2)]), 1);
    });
  });

  testWidgets('a new tournament opens on round 1 even when another one was open before', (tester) async {
    late TournamentProvider provider;
    late int newId;
    await tester.runAsync(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final dir = await Directory.systemTemp.createTemp('fixtura_first_round_test');
      await databaseFactory.setDatabasesPath(dir.path);

      provider = TournamentProvider();
      await provider.clearAllTournaments();
      // A league that was opened earlier and is on round 4
      final oldId = await provider.createTournament(
        name: 'Summer League',
        type: TournamentType.roundRobin,
        legs: 1,
        teamNames: List.generate(8, (i) => 'P$i'),
      );
      await provider.loadTournamentDetails(oldId!);
      for (final match in provider.activeMatches.where((m) => m.roundNumber <= 3)) {
        await provider.updateMatchScore(match.id!, 1, 0);
      }
      newId = (await provider.createTournament(
        name: 'Test Groups',
        type: TournamentType.groupsKnockout,
        legs: 1,
        teamNames: ['Ali', 'Bob', 'Cyn', 'Dan'],
        groupCount: 2,
        qualifiersPerGroup: 1,
      ))!;
    });
    expect(provider.activeTournament!.name, 'Summer League', reason: 'the old tournament is still loaded');

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TournamentDetailsScreen(tournamentId: newId),
      ),
    ));
    // Let the real database load finish between frames
    for (var i = 0; i < 20 && provider.activeTournament?.id != newId; i++) {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    await tester.pump();

    expect(find.text('No matches in this round.'), findsNothing);
    expect(find.byType(CustomMatchCard), findsNWidgets(2), reason: 'round 1: one match per group');
    expect(find.text('GROUP A'), findsOneWidget);
  });
}
