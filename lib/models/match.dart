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
    );
  }

  MatchModel copyWith({
    int? id,
    int? tournamentId,
    int? homeTeamId,
    int? awayTeamId,
    int? homeScore,
    int? awayScore,
    bool? isPlayed,
    int? roundNumber,
    String? roundName,
    int? bracketPos,
    int? nextMatchId,
    bool? nextMatchIsHome,
  }) {
    return MatchModel(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      isPlayed: isPlayed ?? this.isPlayed,
      roundNumber: roundNumber ?? this.roundNumber,
      roundName: roundName ?? this.roundName,
      bracketPos: bracketPos ?? this.bracketPos,
      nextMatchId: nextMatchId ?? this.nextMatchId,
      nextMatchIsHome: nextMatchIsHome ?? this.nextMatchIsHome,
    );
  }
}
