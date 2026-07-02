enum TournamentType { roundRobin, knockout }

class Tournament {
  final int? id;
  final String name;
  final TournamentType type;
  final int legs; // 1 for single, 2 for double round-robin
  final int pointsForWin;
  final int pointsForDraw;
  final int pointsForLoss;
  final DateTime createdAt;
  final String status; // 'active', 'completed'

  Tournament({
    this.id,
    required this.name,
    required this.type,
    this.legs = 1,
    this.pointsForWin = 3,
    this.pointsForDraw = 1,
    this.pointsForLoss = 0,
    required this.createdAt,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'legs': legs,
      'points_for_win': pointsForWin,
      'points_for_draw': pointsForDraw,
      'points_for_loss': pointsForLoss,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory Tournament.fromMap(Map<String, dynamic> map) {
    return Tournament(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: TournamentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TournamentType.roundRobin,
      ),
      legs: map['legs'] as int? ?? 1,
      pointsForWin: map['points_for_win'] as int? ?? 3,
      pointsForDraw: map['points_for_draw'] as int? ?? 1,
      pointsForLoss: map['points_for_loss'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      status: map['status'] as String? ?? 'active',
    );
  }

  Tournament copyWith({
    int? id,
    String? name,
    TournamentType? type,
    int? legs,
    int? pointsForWin,
    int? pointsForDraw,
    int? pointsForLoss,
    DateTime? createdAt,
    String? status,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      legs: legs ?? this.legs,
      pointsForWin: pointsForWin ?? this.pointsForWin,
      pointsForDraw: pointsForDraw ?? this.pointsForDraw,
      pointsForLoss: pointsForLoss ?? this.pointsForLoss,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
