class Team {
  final int? id;
  final int tournamentId;
  final String name;
  final String? colorHex; // Hex color code for team personalization (e.g. #FF5733)
  final String? assignedTeam; // Assigned real team name if roulette is active (e.g. "Real Madrid")

  Team({
    this.id,
    required this.tournamentId,
    required this.name,
    this.colorHex,
    this.assignedTeam,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tournament_id': tournamentId,
      'name': name,
      'color_hex': colorHex,
      'assigned_team': assignedTeam,
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] as int?,
      tournamentId: map['tournament_id'] as int,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String?,
      assignedTeam: map['assigned_team'] as String?,
    );
  }

  Team copyWith({
    int? id,
    int? tournamentId,
    String? name,
    String? colorHex,
    String? assignedTeam,
    bool clearAssignedTeam = false,
  }) {
    return Team(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      assignedTeam: clearAssignedTeam ? null : (assignedTeam ?? this.assignedTeam),
    );
  }
}
