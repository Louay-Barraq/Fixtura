class Team {
  final int? id;
  final int tournamentId;
  final String name;
  final String? colorHex; // Hex color code for team personalization (e.g. #FF5733)

  Team({
    this.id,
    required this.tournamentId,
    required this.name,
    this.colorHex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tournament_id': tournamentId,
      'name': name,
      'color_hex': colorHex,
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] as int?,
      tournamentId: map['tournament_id'] as int,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String?,
    );
  }

  Team copyWith({
    int? id,
    int? tournamentId,
    String? name,
    String? colorHex,
  }) {
    return Team(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
