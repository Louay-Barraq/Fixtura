import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/tournament.dart';
import '../models/team.dart';
import '../models/match.dart';
import '../models/standing.dart';
import '../logic/tournament_rules.dart';

/// Why an auto draft stopped. [round] and [player] are set when the pool ran
/// out of teams for that player; otherwise the draft failed for another reason.
class RouletteDraftError implements Exception {
  final int? round;
  final String? player;

  const RouletteDraftError({this.round, this.player});
}

class TournamentProvider extends ChangeNotifier {
  List<Tournament> _tournaments = [];
  Tournament? _activeTournament;
  List<Team> _activeTeams = [];
  List<MatchModel> _activeMatches = [];
  Map<int, Map<int, String>> _activeRouletteAssignments = {};
  bool _isLoading = false;

  List<Tournament> get tournaments => _tournaments;
  Tournament? get activeTournament => _activeTournament;
  List<Team> get activeTeams => _activeTeams;
  List<MatchModel> get activeMatches => _activeMatches;
  bool get isLoading => _isLoading;

  Map<int, List<MatchModel>> _tournamentMatches = {};
  Map<int, List<Team>> _tournamentTeams = {};
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<MatchModel> getMatchesForTournamentId(int id) {
    if (_activeTournament?.id == id) return _activeMatches;
    return _tournamentMatches[id] ?? [];
  }

  List<Team> getTeamsForTournamentId(int id) {
    if (_activeTournament?.id == id) return _activeTeams;
    return _tournamentTeams[id] ?? [];
  }

  // Calculate tournament progress percentage (0 to 100)
  int calculateTournamentProgress(TournamentType type, List<MatchModel> matches) =>
      tournamentProgress(type, matches);

  // Calculate tournament status ('active' vs 'completed') based on progress
  String calculateTournamentStatus(TournamentType type, List<MatchModel> matches) {
    if (matches.isEmpty) return 'active';
    final progress = calculateTournamentProgress(type, matches);
    return progress >= 100 ? 'completed' : 'active';
  }

  // Fetch all tournaments (for dashboard/history list)
  Future<void> loadAllTournaments() async {
    _isLoading = true;
    notifyListeners();
    try {
      final rawTournaments = await _dbHelper.getAllTournaments();
      final matchesMap = <int, List<MatchModel>>{};
      final teamsMap = <int, List<Team>>{};
      final updatedTournaments = <Tournament>[];

      for (final t in rawTournaments) {
        if (t.id != null) {
          final tMatches = await _dbHelper.getMatchesForTournament(t.id!);
          final tTeams = await _dbHelper.getTeamsForTournament(t.id!);
          matchesMap[t.id!] = tMatches;
          teamsMap[t.id!] = tTeams;

          final computedStatus = calculateTournamentStatus(t.type, tMatches);
          if (t.status != computedStatus) {
            final updatedT = t.copyWith(status: computedStatus);
            await _dbHelper.updateTournament(updatedT);
            updatedTournaments.add(updatedT);
          } else {
            updatedTournaments.add(t);
          }
        } else {
          updatedTournaments.add(t);
        }
      }
      _tournaments = updatedTournaments;
      _tournamentMatches = matchesMap;
      _tournamentTeams = teamsMap;
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
      // Read everything first and swap it in together, so a rebuild during
      // the load never mixes this tournament with the previous one's matches.
      final tournament = await _dbHelper.getTournament(id);
      if (tournament != null) {
        final teams = await _dbHelper.getTeamsForTournament(id);
        final matches = await _dbHelper.getMatchesForTournament(id);
        final roulette = await _loadRouletteAssignments(id);
        _activeTournament = tournament;
        _activeTeams = teams;
        _activeMatches = matches;
        _activeRouletteAssignments = roulette;

        final computedStatus = calculateTournamentStatus(
          _activeTournament!.type,
          _activeMatches,
        );
        if (_activeTournament!.status != computedStatus) {
          _activeTournament = _activeTournament!.copyWith(status: computedStatus);
          await _dbHelper.updateTournament(_activeTournament!);
          final idx = _tournaments.indexWhere((t) => t.id == id);
          if (idx != -1) {
            _tournaments[idx] = _activeTournament!;
          }
        }
      } else {
        _activeTournament = null;
        _activeTeams = [];
        _activeMatches = [];
        _activeRouletteAssignments = {};
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
    bool useRoulette = false,
    List<String> roulettePool = const [],
    bool rouletteUnique = true,
    bool rouletteRoundUnique = true,
    int groupCount = 0,
    int qualifiersPerGroup = 0,
  }) async {
    final isGroups = type == TournamentType.groupsKnockout;
    if (isGroups &&
        (!groupCountOptions.contains(groupCount) ||
            !qualifierOptions.contains(qualifiersPerGroup) ||
            teamNames.length < minPlayersForGroups(groupCount, qualifiersPerGroup))) {
      debugPrint('Invalid group setup: $groupCount groups, $qualifiersPerGroup qualifiers, ${teamNames.length} players');
      return null;
    }

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
          useRoulette: useRoulette,
          roulettePool: roulettePool,
          rouletteUnique: rouletteUnique,
          rouletteRoundUnique: rouletteRoundUnique,
          groupCount: isGroups ? groupCount : 0,
          qualifiersPerGroup: isGroups ? qualifiersPerGroup : 0,
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
            // Deal players into groups in entry order: A, B, C, ..., A, B, ...
            groupIndex: isGroups ? i % groupCount : null,
          );
          final teamId = await _dbHelper.insertTeam(team, txn);
          insertedTeams.add(team.copyWith(id: teamId));
        }

        // 3. Generate Matches/Fixtures
        if (type == TournamentType.roundRobin) {
          await _generateRoundRobinFixtures(tournamentId!, insertedTeams, legs, txn);
        } else if (type == TournamentType.knockout) {
          await _generateKnockoutFixtures(tournamentId!, insertedTeams, txn);
        } else {
          await _generateGroupsKnockoutFixtures(tournament.copyWith(id: tournamentId), insertedTeams, txn);
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

  // Update tournament settings and player names
  Future<bool> updateTournamentSettings({
    required int tournamentId,
    required String name,
    required int pointsWin,
    required int pointsDraw,
    required int pointsLoss,
    required bool useRoulette,
    required List<String> roulettePool,
    required bool rouletteUnique,
    required bool rouletteRoundUnique,
    Map<int, String>? updatedPlayerNames,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        // 1. Fetch current tournament
        final current = await _dbHelper.getTournament(tournamentId, txn);
        if (current == null) return;

        final updatedTournament = current.copyWith(
          name: name,
          pointsForWin: pointsWin,
          pointsForDraw: pointsDraw,
          pointsForLoss: pointsLoss,
          useRoulette: useRoulette,
          roulettePool: roulettePool,
          rouletteUnique: rouletteUnique,
          rouletteRoundUnique: rouletteRoundUnique,
        );

        await _dbHelper.updateTournament(updatedTournament, txn);

        // 2. Update player names if provided
        if (updatedPlayerNames != null) {
          for (final entry in updatedPlayerNames.entries) {
            final teamId = entry.key;
            final newName = entry.value.trim();
            if (newName.isNotEmpty) {
              await txn.rawUpdate(
                'UPDATE teams SET name = ? WHERE id = ?',
                [newName, teamId],
              );
            }
          }
        }
      });

      await loadTournamentDetails(tournamentId);
      await loadAllTournaments();
      return true;
    } catch (e) {
      debugPrint("Error updating tournament settings: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<int, Map<int, String>>> _loadRouletteAssignments(int tournamentId) async {
    final rows = await _dbHelper.getRouletteAssignmentsForTournament(tournamentId);
    final assignments = <int, Map<int, String>>{};

    for (final row in rows) {
      final teamId = row['team_id'] as int;
      final roundNumber = row['round_number'] as int;
      final assignedTeam = row['assigned_team'] as String;
      assignments.putIfAbsent(teamId, () => {})[roundNumber] = assignedTeam;
    }

    return assignments;
  }

  String? getRouletteAssignmentForTeamRound(int teamId, int roundNumber) {
    return _activeRouletteAssignments[teamId]?[roundNumber];
  }

  List<String> getAvailableRouletteTeamsForPlayer(Team team, int roundNumber) {
    return _getAvailableRouletteTeamsForPlayer(
      team: team,
      roundNumber: roundNumber,
      assignmentsByTeam: _activeRouletteAssignments,
    );
  }

  List<String> _getAvailableRouletteTeamsForPlayer({
    required Team team,
    required int roundNumber,
    required Map<int, Map<int, String>> assignmentsByTeam,
  }) {
    final tournament = _activeTournament;
    if (tournament == null) return const [];

    final usedTeams = <String>{};

    // Constraint 1 (rouletteRoundUnique): this player must not get a team
    // they already hold in any OTHER round.
    if (tournament.rouletteRoundUnique) {
      final assignmentsForTeam = assignmentsByTeam[team.id] ?? const {};
      for (final entry in assignmentsForTeam.entries) {
        if (entry.key != roundNumber) {
          usedTeams.add(entry.value);
        }
      }
    }

    // Constraint 2 (rouletteUnique): no two players may hold the same team
    // in the SAME round.
    if (tournament.rouletteUnique) {
      for (final entry in assignmentsByTeam.entries) {
        if (entry.key == team.id) continue; // skip self
        final teamForRound = entry.value[roundNumber];
        if (teamForRound != null) {
          usedTeams.add(teamForRound);
        }
      }
    }

    return tournament.roulettePool
        .where((option) => !usedTeams.contains(option))
        .toList();
  }

  List<int> getRouletteRounds() {
    final rounds = _activeMatches.map((match) => match.roundNumber).toSet().toList();
    rounds.sort();
    return rounds;
  }

  bool hasRouletteAssignmentsForRound(int roundNumber) {
    return _activeRouletteAssignments.values.any((roundAssignments) => roundAssignments.containsKey(roundNumber));
  }

  Future<void> setRouletteAssignment(int teamId, int roundNumber, String teamName) async {
    if (_activeTournament == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        await _dbHelper.upsertRouletteAssignment(
          tournamentId: _activeTournament!.id!,
          teamId: teamId,
          roundNumber: roundNumber,
          assignedTeam: teamName,
          executor: txn,
        );
      });
      
      // Reload state
      if (_activeTournament?.id != null) {
        await loadTournamentDetails(_activeTournament!.id!);
      }
    } catch (e) {
      debugPrint("Error assigning roulette team: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetRouletteRound(int roundNumber) async {
    if (_activeTournament == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        await _dbHelper.deleteRouletteAssignments(
          tournamentId: _activeTournament!.id!,
          roundNumber: roundNumber,
          executor: txn,
        );
      });
      
      // Reload state
      if (_activeTournament?.id != null) {
        await loadTournamentDetails(_activeTournament!.id!);
      }
    } catch (e) {
      debugPrint("Error resetting roulette: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetRouletteAllRounds() async {
    if (_activeTournament == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        await _dbHelper.deleteRouletteAssignments(
          tournamentId: _activeTournament!.id!,
          executor: txn,
        );
      });

      if (_activeTournament?.id != null) {
        await loadTournamentDetails(_activeTournament!.id!);
      }
    } catch (e) {
      debugPrint("Error resetting all roulette rounds: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<RouletteDraftError?> autoDraftRound(int roundNumber) async {
    if (_activeTournament == null) return const RouletteDraftError();

    _isLoading = true;
    notifyListeners();

    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        final random = Random();
        final workingAssignments = <int, Map<int, String>>{};

        for (final entry in _activeRouletteAssignments.entries) {
          workingAssignments[entry.key] = Map<int, String>.from(entry.value);
        }

        for (final team in _activeTeams) {
          final availableTeams = _getAvailableRouletteTeamsForPlayer(
            team: team,
            roundNumber: roundNumber,
            assignmentsByTeam: workingAssignments,
          );

          if (availableTeams.isEmpty) {
            if (_activeTournament!.rouletteUnique || _activeTournament!.rouletteRoundUnique) {
              throw RouletteDraftError(round: roundNumber, player: team.name);
            }
            continue;
          }

          final selectedTeam = availableTeams[random.nextInt(availableTeams.length)];
          await _dbHelper.upsertRouletteAssignment(
            tournamentId: _activeTournament!.id!,
            teamId: team.id!,
            roundNumber: roundNumber,
            assignedTeam: selectedTeam,
            executor: txn,
          );

          workingAssignments.putIfAbsent(team.id!, () => {})[roundNumber] = selectedTeam;
        }
      });

      if (_activeTournament?.id != null) {
        await loadTournamentDetails(_activeTournament!.id!);
      }
      return null;
    } catch (e) {
      debugPrint("Error auto drafting round $roundNumber: $e");
      return e is RouletteDraftError ? e : const RouletteDraftError();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<RouletteDraftError?> autoDraftAllRounds() async {
    if (_activeTournament == null) return const RouletteDraftError();
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        final random = Random();
        final rounds = getRouletteRounds();
        final workingAssignments = <int, Map<int, String>>{};

        for (final entry in _activeRouletteAssignments.entries) {
          workingAssignments[entry.key] = Map<int, String>.from(entry.value);
        }

        for (final roundNumber in rounds) {
          for (final team in _activeTeams) {
            final availableTeams = _getAvailableRouletteTeamsForPlayer(
              team: team,
              roundNumber: roundNumber,
              assignmentsByTeam: workingAssignments,
            );
            if (availableTeams.isEmpty) {
              if (_activeTournament!.rouletteUnique || _activeTournament!.rouletteRoundUnique) {
                throw RouletteDraftError(round: roundNumber, player: team.name);
              }
              continue;
            }

            final selectedTeam = availableTeams[random.nextInt(availableTeams.length)];
            await _dbHelper.upsertRouletteAssignment(
              tournamentId: _activeTournament!.id!,
              teamId: team.id!,
              roundNumber: roundNumber,
              assignedTeam: selectedTeam,
              executor: txn,
            );

            workingAssignments.putIfAbsent(team.id!, () => {})[roundNumber] = selectedTeam;
          }
        }
      });
      
      // Reload state
      if (_activeTournament?.id != null) {
        await loadTournamentDetails(_activeTournament!.id!);
      }
      return null;
    } catch (e) {
      debugPrint("Error in auto draft: $e");
      return e is RouletteDraftError ? e : const RouletteDraftError();
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
    int? groupIndex,
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
            groupIndex: groupIndex,
          );

          await _dbHelper.insertMatch(match, txn);
        }
      }
    }
  }

  // Build an empty bracket for [slotCount] entrants (rounded up to a power of
  // two) from the final backwards, numbering its rounds after [roundOffset].
  // Returns the first-round matches in bracket order.
  Future<List<MatchModel>> _buildBracket(
    int tournamentId,
    int slotCount,
    int roundOffset,
    DatabaseExecutor? txn,
  ) async {
    int p = 1;
    while (p < slotCount) {
      p *= 2;
    }

    final totalRounds = (log(p) / log(2)).round(); // e.g. 8 slots = 3 rounds
    List<MatchModel> previousRoundMatches = [];

    // rIdx = 0 is the final, rIdx = totalRounds - 1 is the first round
    for (int rIdx = 0; rIdx < totalRounds; rIdx++) {
      final roundMatchesCount = 1 << rIdx; // 1, 2, 4, 8...
      final bracketRound = totalRounds - rIdx;
      final roundName = _getKnockoutRoundName(bracketRound, totalRounds);
      final List<MatchModel> currentRoundMatches = [];

      for (int mIdx = 0; mIdx < roundMatchesCount; mIdx++) {
        int? nextMatchId;
        bool? nextMatchIsHome;

        if (rIdx > 0) {
          // Link to the match one round closer to the final
          nextMatchId = previousRoundMatches[mIdx ~/ 2].id;
          nextMatchIsHome = mIdx % 2 == 0;
        }

        final match = MatchModel(
          tournamentId: tournamentId,
          roundNumber: roundOffset + bracketRound,
          roundName: roundName,
          bracketPos: mIdx,
          nextMatchId: nextMatchId,
          nextMatchIsHome: nextMatchIsHome,
        );

        final insertedId = await _dbHelper.insertMatch(match, txn);
        currentRoundMatches.add(match.copyWith(id: insertedId));
      }

      previousRoundMatches = currentRoundMatches;
    }

    return previousRoundMatches;
  }

  // Generate Knockout matches (bracket tree) and seed the players in order
  Future<void> _generateKnockoutFixtures(int tournamentId, List<Team> teams, [DatabaseExecutor? txn]) async {
    final n = teams.length;
    if (n < 2) return;

    final firstRoundMatches = await _buildBracket(tournamentId, n, 0, txn);
    final k = firstRoundMatches.length; // e.g., 4 matches for 8 slots

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

  // Generate a league per group, then an empty bracket after the group
  // rounds. The bracket is filled once every group match is played.
  Future<void> _generateGroupsKnockoutFixtures(
    Tournament tournament,
    List<Team> teams, [
    DatabaseExecutor? txn,
  ]) async {
    var groupRounds = 0;
    for (var g = 0; g < tournament.groupCount; g++) {
      final groupTeams = teams.where((t) => t.groupIndex == g).toList();
      await _generateRoundRobinFixtures(tournament.id!, groupTeams, tournament.legs, txn, g);
      final effective = groupTeams.length.isOdd ? groupTeams.length + 1 : groupTeams.length;
      groupRounds = max(groupRounds, tournament.legs * (effective - 1));
    }

    await _buildBracket(
      tournament.id!,
      tournament.groupCount * tournament.qualifiersPerGroup,
      groupRounds,
      txn,
    );
  }

  // Put the group qualifiers into the first bracket round, or empty it while
  // group matches remain. A first-round match whose teams change loses its
  // result, and so does every later match it fed.
  Future<void> _syncKnockoutSlots(Tournament tournament, DatabaseExecutor txn) async {
    final teams = await _dbHelper.getTeamsForTournament(tournament.id!, txn);
    final matches = await _dbHelper.getMatchesForTournament(tournament.id!, txn);
    final slots = knockoutSlots(tournament, teams, matches);
    final firstRound = _firstBracketRound(matches);

    for (var i = 0; i < firstRound.length; i++) {
      final match = firstRound[i];
      final home = slots[2 * i];
      final away = slots[2 * i + 1];
      if (match.homeTeamId == home && match.awayTeamId == away) continue;

      final updated = match.copyWith(homeTeamId: home, awayTeamId: away);
      if (match.isPlayed) {
        await _resetMatchAndDownstream(updated, txn);
      } else {
        await _dbHelper.updateMatch(updated, txn);
      }
    }
  }

  List<MatchModel> _firstBracketRound(List<MatchModel> matches) {
    final bracket = matches.where((m) => m.groupIndex == null).toList();
    if (bracket.isEmpty) return const [];
    final firstRound = bracket.map((m) => m.roundNumber).reduce(min);
    return bracket.where((m) => m.roundNumber == firstRound).toList()
      ..sort((a, b) => (a.bracketPos ?? 0).compareTo(b.bracketPos ?? 0));
  }

  String _getKnockoutRoundName(int roundNumber, int totalRounds) {
    final roundsFromFinal = totalRounds - roundNumber;
    if (roundsFromFinal == 0) return "Final";
    if (roundsFromFinal == 1) return "Semi-finals";
    if (roundsFromFinal == 2) return "Quarter-finals";
    return "Round of ${1 << (roundsFromFinal + 1)}";
  }

  // The earliest already-played match that saving this score would clear,
  // if any. Pass null scores when the result is being reset.
  MatchModel? laterMatchClearedBy(MatchModel match, int? homeScore, int? awayScore) {
    final tournament = _activeTournament;
    if (tournament == null) return null;

    if (tournament.type == TournamentType.groupsKnockout && match.groupIndex != null) {
      return _bracketMatchClearedByGroupResult(tournament, match, homeScore, awayScore);
    }
    if (!isKnockoutStage(tournament.type, match) || match.nextMatchId == null) {
      return null;
    }

    final nextIndex = _activeMatches.indexWhere((m) => m.id == match.nextMatchId);
    if (nextIndex == -1) return null;
    final nextMatch = _activeMatches[nextIndex];
    if (!nextMatch.isPlayed) return null;

    if (homeScore == null || awayScore == null) return nextMatch;
    if (homeScore == awayScore) return null;

    final winnerId = homeScore > awayScore ? match.homeTeamId : match.awayTeamId;
    final advancedId = match.nextMatchIsHome == true ? nextMatch.homeTeamId : nextMatch.awayTeamId;
    return winnerId == advancedId ? null : nextMatch;
  }

  // A group result can change who qualifies. Works out the bracket this score
  // would produce and returns the earliest played bracket match it would clear.
  MatchModel? _bracketMatchClearedByGroupResult(
    Tournament tournament,
    MatchModel match,
    int? homeScore,
    int? awayScore,
  ) {
    final bracket = _activeMatches.where((m) => m.groupIndex == null).toList();
    if (!bracket.any((m) => m.isPlayed)) return null;

    final played = homeScore != null && awayScore != null;
    final simulated = [
      for (final m in _activeMatches)
        m.id == match.id
            ? m.copyWith(homeScore: homeScore, awayScore: awayScore, isPlayed: played)
            : m,
    ];
    final newSlots = knockoutSlots(tournament, _activeTeams, simulated);
    final firstRound = _firstBracketRound(_activeMatches);

    final affected = <MatchModel>[];
    for (var i = 0; i < firstRound.length; i++) {
      final current = firstRound[i];
      if (current.homeTeamId == newSlots[2 * i] && current.awayTeamId == newSlots[2 * i + 1]) continue;
      // Everything this match feeds is affected too
      MatchModel? next = current;
      while (next != null) {
        affected.add(next);
        final nextId = next.nextMatchId;
        next = nextId == null ? null : bracket.where((m) => m.id == nextId).firstOrNull;
      }
    }

    final cleared = affected.where((m) => m.isPlayed).toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));
    return cleared.isEmpty ? null : cleared.first;
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
        final tournament = await _dbHelper.getTournament(match.tournamentId, txn);
        if (tournament == null) return;

        final updatedMatch = match.copyWith(
          homeScore: homeScore,
          awayScore: awayScore,
          isPlayed: homeScore != null && awayScore != null,
        );

        await _dbHelper.updateMatch(updatedMatch, txn);

        if (isKnockoutStage(tournament.type, updatedMatch)) {
          // Bracket match: move the winner on
          if (updatedMatch.isPlayed) {
            await _propagateWinner(updatedMatch, txn);
          } else {
            // If match is cleared/unplayed, reset downstream
            await _resetMatchAndDownstream(updatedMatch, txn);
          }
        } else if (tournament.type == TournamentType.groupsKnockout) {
          // Group match: the qualifiers may have changed
          await _syncKnockoutSlots(tournament, txn);
        }
      });

      // Reload active matches and details
      if (_activeTournament != null) {
        _activeMatches = await _dbHelper.getMatchesForTournament(_activeTournament!.id!);
        _tournamentMatches[_activeTournament!.id!] = _activeMatches;

        final computedStatus = calculateTournamentStatus(
          _activeTournament!.type,
          _activeMatches,
        );
        if (_activeTournament!.status != computedStatus) {
          _activeTournament = _activeTournament!.copyWith(status: computedStatus);
          await _dbHelper.updateTournament(_activeTournament!);
          final idx = _tournaments.indexWhere((t) => t.id == _activeTournament!.id);
          if (idx != -1) {
            _tournaments[idx] = _activeTournament!;
          }
        }
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

  // Clear all tournaments and reset state
  Future<void> clearAllTournaments() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _dbHelper.clearAllData();
      _activeTournament = null;
      _activeTeams = [];
      _activeMatches = [];
      _activeRouletteAssignments = {};
      _tournaments = [];
      _tournamentMatches = {};
      _tournamentTeams = {};
    } catch (e) {
      debugPrint("Error clearing all tournaments: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // League table for a round-robin tournament
  List<Standing> calculateStandings() {
    final t = _activeTournament;
    if (t == null || t.type != TournamentType.roundRobin) return [];
    return computeStandings(_activeTeams, _activeMatches, t.pointsForWin, t.pointsForDraw, t.pointsForLoss);
  }

  // One table per group for a groups + knockout tournament
  List<List<Standing>> calculateGroupStandings() {
    final t = _activeTournament;
    if (t == null || t.type != TournamentType.groupsKnockout) return [];
    return computeGroupStandings(t, _activeTeams, _activeMatches);
  }

  int? get championTeamId {
    final t = _activeTournament;
    if (t == null) return null;
    return championId(t, _activeTeams, _activeMatches);
  }
}
