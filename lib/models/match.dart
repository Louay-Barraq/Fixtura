const Object _keep = Object();

class MatchModel {
  final int? id;
  final int tournamentId;
  final int? homeTeamId;
  final int? awayTeamId;
  final int? homeScore;
  final int? awayScore;
  final bool isPlayed;
  final int roundNumber;
  final String roundName;
  final int? bracketPos; // Match position in the current round (for bracket display)
  final int? nextMatchId; // Next match ID where the winner advances
  final bool? nextMatchIsHome; // Whether the winner is home (true) or away (false) in the next match
  final int? groupIndex; // Group (0 = A) for a group-stage match; null in a league or knockout

  MatchModel({
    this.id,
    required this.tournamentId,
    this.homeTeamId,
    this.awayTeamId,
    this.homeScore,
    this.awayScore,
    this.isPlayed = false,
    required this.roundNumber,
    required this.roundName,
    this.bracketPos,
    this.nextMatchId,
    this.nextMatchIsHome,
    this.groupIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tournament_id': tournamentId,
      'home_team_id': homeTeamId,
      'away_team_id': awayTeamId,
      'home_score': homeScore,
      'away_score': awayScore,
      'is_played': isPlayed ? 1 : 0,
      'round_number': roundNumber,
      'round_name': roundName,
      'bracket_pos': bracketPos,
      'next_match_id': nextMatchId,
      'next_match_is_home': nextMatchIsHome == null ? null : (nextMatchIsHome! ? 1 : 0),
      'group_index': groupIndex,
    };
  }

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'] as int?,
      tournamentId: map['tournament_id'] as int,
      homeTeamId: map['home_team_id'] as int?,
      awayTeamId: map['away_team_id'] as int?,
      homeScore: map['home_score'] as int?,
      awayScore: map['away_score'] as int?,
      isPlayed: (map['is_played'] as int? ?? 0) == 1,
      roundNumber: map['round_number'] as int,
      roundName: map['round_name'] as String,
      bracketPos: map['bracket_pos'] as int?,
      nextMatchId: map['next_match_id'] as int?,
      nextMatchIsHome: map['next_match_is_home'] == null
          ? null
          : (map['next_match_is_home'] as int) == 1,
      groupIndex: map['group_index'] as int?,
    );
  }

  // Team and score fields can be cleared by passing null explicitly, so they
  // default to a marker that means "keep the current value".
  MatchModel copyWith({
    int? id,
    int? tournamentId,
    Object? homeTeamId = _keep,
    Object? awayTeamId = _keep,
    Object? homeScore = _keep,
    Object? awayScore = _keep,
    bool? isPlayed,
    int? roundNumber,
    String? roundName,
    int? bracketPos,
    int? nextMatchId,
    bool? nextMatchIsHome,
    int? groupIndex,
  }) {
    return MatchModel(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      homeTeamId: identical(homeTeamId, _keep) ? this.homeTeamId : homeTeamId as int?,
      awayTeamId: identical(awayTeamId, _keep) ? this.awayTeamId : awayTeamId as int?,
      homeScore: identical(homeScore, _keep) ? this.homeScore : homeScore as int?,
      awayScore: identical(awayScore, _keep) ? this.awayScore : awayScore as int?,
      isPlayed: isPlayed ?? this.isPlayed,
      roundNumber: roundNumber ?? this.roundNumber,
      roundName: roundName ?? this.roundName,
      bracketPos: bracketPos ?? this.bracketPos,
      nextMatchId: nextMatchId ?? this.nextMatchId,
      nextMatchIsHome: nextMatchIsHome ?? this.nextMatchIsHome,
      groupIndex: groupIndex ?? this.groupIndex,
    );
  }
}
