import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/tournament.dart';
import '../models/team.dart';
import '../models/match.dart';
import '../models/standing.dart';

class TournamentProvider extends ChangeNotifier {
  List<Tournament> _tournaments = [];
  Tournament? _activeTournament;
  List<Team> _activeTeams = [];
  List<MatchModel> _activeMatches = [];
  bool _isLoading = false;

  List<Tournament> get tournaments => _tournaments;
  Tournament? get activeTournament => _activeTournament;
  List<Team> get activeTeams => _activeTeams;
  List<MatchModel> get activeMatches => _activeMatches;
  bool get isLoading => _isLoading;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Fetch all tournaments (for dashboard/history list)
  Future<void> loadAllTournaments() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tournaments = await _dbHelper.getAllTournaments();
    } catch (e) {
      debugPrint("Error loading tournaments: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load a single tournament and its teams/matches
  Future<void> loadTournamentDetails(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _activeTournament = await _dbHelper.getTournament(id);
      if (_activeTournament != null) {
        _activeTeams = await _dbHelper.getTeamsForTournament(id);
        _activeMatches = await _dbHelper.getMatchesForTournament(id);
      }
    } catch (e) {
      debugPrint("Error loading tournament details: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new tournament
  Future<int?> createTournament({
    required String name,
    required TournamentType type,
    required int legs,
    required List<String> teamNames,
    int pointsWin = 3,
    int pointsDraw = 1,
    int pointsLoss = 0,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await _dbHelper.database;
      int? tournamentId;

      await db.transaction((txn) async {
        // 1. Insert Tournament
        final tournament = Tournament(
          name: name,
          type: type,
          legs: legs,
          pointsForWin: pointsWin,
          pointsForDraw: pointsDraw,
          pointsForLoss: pointsLoss,
          createdAt: DateTime.now(),
        );
        tournamentId = await _dbHelper.insertTournament(tournament, txn);

        // 2. Insert Teams
        final List<Team> insertedTeams = [];
        final List<String> colors = [
          '#FF3B30', '#FF9500', '#FFCC00', '#34C759', 
          '#007AFF', '#5856D6', '#AF52DE', '#FF2D55',
          '#5AC8FA', '#4CD964', '#000000', '#8E8E93'
        ];
        
        for (int i = 0; i < teamNames.length; i++) {
          final teamColor = colors[i % colors.length];
          final team = Team(
            tournamentId: tournamentId!,
            name: teamNames[i].trim(),
            colorHex: teamColor,
          );
          final teamId = await _dbHelper.insertTeam(team, txn);
          insertedTeams.add(team.copyWith(id: teamId));
        }

        // 3. Generate Matches/Fixtures
        if (type == TournamentType.roundRobin) {
          await _generateRoundRobinFixtures(tournamentId!, insertedTeams, legs, txn);
        } else if (type == TournamentType.knockout) {
          await _generateKnockoutFixtures(tournamentId!, insertedTeams, txn);
        }
      });

      // Refresh listings
      await loadAllTournaments();
      return tournamentId;
    } catch (e) {
      debugPrint("Error creating tournament: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate Round Robin matches using Circle Method
  Future<void> _generateRoundRobinFixtures(
    int tournamentId,
    List<Team> teams,
    int legs, [
    DatabaseExecutor? txn,
  ]) async {
    // If odd number of teams, add a dummy team representing a BYE (id = null)
    List<Team?> list = List.from(teams);
    bool hasBye = list.length % 2 != 0;
    if (hasBye) {
      list.add(null); // null indicates a BYE
    }

    int numTeams = list.length;
    int numRounds = numTeams - 1;
    int matchesPerRound = numTeams ~/ 2;

    // We do one loop for Leg 1, and another if Leg 2 is enabled
    for (int leg = 1; leg <= legs; leg++) {
      for (int round = 0; round < numRounds; round++) {
        final roundNum = (leg - 1) * numRounds + round + 1;
        final roundName = "Round $roundNum";

        for (int matchIdx = 0; matchIdx < matchesPerRound; matchIdx++) {
          int homeIdx = (round + matchIdx) % (numTeams - 1);
          int awayIdx = (numTeams - 1 - matchIdx + round) % (numTeams - 1);

          // Fixed team position
          if (matchIdx == 0) {
            homeIdx = numTeams - 1;
          }

          var homeTeam = list[homeIdx];
          var awayTeam = list[awayIdx];

          // Alternate home/away for consecutive legs
          if (leg % 2 == 0) {
            final temp = homeTeam;
            homeTeam = awayTeam;
            awayTeam = temp;
          }

          // Generate match
          final isByeMatch = homeTeam == null || awayTeam == null;
          final match = MatchModel(
            tournamentId: tournamentId,
            homeTeamId: homeTeam?.id,
            awayTeamId: awayTeam?.id,
            roundNumber: roundNum,
            roundName: roundName,
            isPlayed: isByeMatch, // BYE matches are instantly "played"
            homeScore: isByeMatch ? 0 : null,
            awayScore: isByeMatch ? 0 : null,
            bracketPos: matchIdx,
          );

          await _dbHelper.insertMatch(match, txn);
        }
      }
    }
  }

  // Generate Knockout matches (bracket tree) backwards
  Future<void> _generateKnockoutFixtures(int tournamentId, List<Team> teams, [DatabaseExecutor? txn]) async {
    final n = teams.length;
    if (n < 2) return;

    // Calculate next power of 2
    int p = 1;
    while (p < n) {
      p *= 2;
    }

    final totalRounds = (log(p) / log(2)).round(); // e.g. 8 teams = 3 rounds
    final List<List<MatchModel>> roundsMatches = [];

    // Step A: Build the empty bracket structure from final round backwards
    // roundIndex = 0 is final round, roundIndex = totalRounds - 1 is the first round
    List<MatchModel> previousRoundMatches = [];

    for (int rIdx = 0; rIdx < totalRounds; rIdx++) {
      final roundMatchesCount = 1 << rIdx; // 1, 2, 4, 8...
      final roundNumber = totalRounds - rIdx;
      final roundName = _getKnockoutRoundName(roundNumber, totalRounds);
      final List<MatchModel> currentRoundMatches = [];

      for (int mIdx = 0; mIdx < roundMatchesCount; mIdx++) {
        int? nextMatchId;
        bool? nextMatchIsHome;

        if (rIdx > 0) {
          // Link to match in previous iteration (closer to final)
          final parentMatchIndex = mIdx ~/ 2;
          nextMatchId = previousRoundMatches[parentMatchIndex].id;
          nextMatchIsHome = mIdx % 2 == 0;
        }

        final match = MatchModel(
          tournamentId: tournamentId,
          roundNumber: roundNumber,
          roundName: roundName,
          bracketPos: mIdx,
          nextMatchId: nextMatchId,
          nextMatchIsHome: nextMatchIsHome,
        );

        final insertedId = await _dbHelper.insertMatch(match, txn);
        currentRoundMatches.add(match.copyWith(id: insertedId));
      }

      previousRoundMatches = currentRoundMatches;
      roundsMatches.add(currentRoundMatches);
    }

    // Step B: Populate first round matches with teams and handle byes
    // The first round matches are in roundsMatches.last (which corresponds to roundNumber = 1)
    final firstRoundMatches = roundsMatches.last;
    final k = firstRoundMatches.length; // e.g., 4 matches for 8 slots

    // Fill home slots
    for (int i = 0; i < k; i++) {
      int? homeTeamId = i < n ? teams[i].id : null;
      int? awayTeamId = (i + k) < n ? teams[i + k].id : null;

      var match = firstRoundMatches[i].copyWith(
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
      );

      // Handle direct bye: if awayTeamId is null, home advances instantly
      if (homeTeamId != null && awayTeamId == null) {
        match = match.copyWith(
          isPlayed: true,
          homeScore: 3, // Walkover score
          awayScore: 0,
        );
      }

      await _dbHelper.updateMatch(match, txn);
      firstRoundMatches[i] = match;

      // Propagate the bye winner forward immediately
      if (match.isPlayed) {
        await _propagateWinner(match, txn);
      }
    }
  }

  String _getKnockoutRoundName(int roundNumber, int totalRounds) {
    final roundsFromFinal = totalRounds - roundNumber;
    if (roundsFromFinal == 0) return "Final";
    if (roundsFromFinal == 1) return "Semi-finals";
    if (roundsFromFinal == 2) return "Quarter-finals";
    return "Round of ${1 << (roundsFromFinal + 1)}";
  }

  // Update a match score
  Future<void> updateMatchScore(int matchId, int? homeScore, int? awayScore) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        final match = await _dbHelper.getMatch(matchId, txn);
        if (match == null) return;

        final updatedMatch = match.copyWith(
          homeScore: homeScore,
          awayScore: awayScore,
          isPlayed: homeScore != null && awayScore != null,
        );

        await _dbHelper.updateMatch(updatedMatch, txn);

        // If it's a knockout tournament, propagate the winner
        if (_activeTournament?.type == TournamentType.knockout) {
          if (updatedMatch.isPlayed) {
            await _propagateWinner(updatedMatch, txn);
          } else {
            // If match is cleared/unplayed, reset downstream
            await _resetMatchAndDownstream(updatedMatch, txn);
          }
        }
      });

      // Reload active matches and details
      if (_activeTournament != null) {
        _activeMatches = await _dbHelper.getMatchesForTournament(_activeTournament!.id!);
      }
    } catch (e) {
      debugPrint("Error updating match score: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset match and recursively reset all linked downstream matches
  Future<void> _resetMatchAndDownstream(MatchModel match, [DatabaseExecutor? txn]) async {
    final resetMatch = match.copyWith(
      homeScore: null,
      awayScore: null,
      isPlayed: false,
    );
    await _dbHelper.updateMatch(resetMatch, txn);

    if (resetMatch.nextMatchId != null) {
      final nextMatch = await _dbHelper.getMatch(resetMatch.nextMatchId!, txn);
      if (nextMatch != null) {
        MatchModel updatedNextMatch;
        if (resetMatch.nextMatchIsHome == true) {
          updatedNextMatch = nextMatch.copyWith(homeTeamId: null);
        } else {
          updatedNextMatch = nextMatch.copyWith(awayTeamId: null);
        }
        await _resetMatchAndDownstream(updatedNextMatch, txn);
      }
    }
  }

  // Propagate the winning team to the next round match
  Future<void> _propagateWinner(MatchModel match, [DatabaseExecutor? txn]) async {
    if (match.nextMatchId == null) return;

    int? winnerId;
    if (match.homeScore != null && match.awayScore != null) {
      if (match.homeScore! > match.awayScore!) {
        winnerId = match.homeTeamId;
      } else if (match.awayScore! > match.homeScore!) {
        winnerId = match.awayTeamId;
      } else {
        // Tie: cannot propagate without a winner. UI must enforce a winner (e.g. penalties)
        return;
      }
    } else {
      // Bye case
      winnerId = match.homeTeamId ?? match.awayTeamId;
    }

    if (winnerId == null) return;

    final nextMatch = await _dbHelper.getMatch(match.nextMatchId!, txn);
    if (nextMatch != null) {
      MatchModel updatedNextMatch;
      if (match.nextMatchIsHome == true) {
        if (nextMatch.homeTeamId == winnerId) return; // Already correct
        updatedNextMatch = nextMatch.copyWith(homeTeamId: winnerId);
      } else {
        if (nextMatch.awayTeamId == winnerId) return; // Already correct
        updatedNextMatch = nextMatch.copyWith(awayTeamId: winnerId);
      }

      // If next match was already played and team has changed, we must reset downstream
      if (nextMatch.isPlayed) {
        await _resetMatchAndDownstream(updatedNextMatch, txn);
      } else {
        await _dbHelper.updateMatch(updatedNextMatch, txn);
      }
    }
  }

  // Delete a tournament
  Future<void> deleteTournament(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _dbHelper.deleteTournament(id);
      if (_activeTournament?.id == id) {
        _activeTournament = null;
        _activeTeams = [];
        _activeMatches = [];
      }
      await loadAllTournaments();
    } catch (e) {
      debugPrint("Error deleting tournament: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate Standings Table on the fly
  List<Standing> calculateStandings() {
    if (_activeTournament == null || _activeTournament!.type != TournamentType.roundRobin) {
      return [];
    }

    // Map each team to a Standing object
    final Map<int, Standing> standingsMap = {
      for (var team in _activeTeams) team.id!: Standing(team: team)
    };

    for (var match in _activeMatches) {
      // Skip BYE matches or unplayed matches
      if (match.homeTeamId == null || match.awayTeamId == null || !match.isPlayed) {
        continue;
      }

      final homeStanding = standingsMap[match.homeTeamId];
      final awayStanding = standingsMap[match.awayTeamId];

      if (homeStanding == null || awayStanding == null) continue;

      homeStanding.played += 1;
      awayStanding.played += 1;

      final hs = match.homeScore ?? 0;
      final as = match.awayScore ?? 0;

      homeStanding.goalsFor += hs;
      homeStanding.goalsAgainst += as;
      awayStanding.goalsFor += as;
      awayStanding.goalsAgainst += hs;

      if (hs > as) {
        homeStanding.won += 1;
        awayStanding.lost += 1;
      } else if (as > hs) {
        awayStanding.won += 1;
        homeStanding.lost += 1;
      } else {
        homeStanding.drawn += 1;
        awayStanding.drawn += 1;
      }
    }

    final result = standingsMap.values.toList();
    
    // Sort standings
    result.sort((a, b) => Standing.compare(
      a,
      b,
      _activeTournament!.pointsForWin,
      _activeTournament!.pointsForDraw,
      _activeTournament!.pointsForLoss,
    ));

    return result;
  }
}
