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
  final bool useRoulette;
  final List<String> roulettePool;
  final bool rouletteUnique;
  final bool rouletteRoundUnique;

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
    this.useRoulette = false,
    this.roulettePool = const [],
    this.rouletteUnique = true,
    this.rouletteRoundUnique = true,
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
      'use_roulette': useRoulette ? 1 : 0,
      'roulette_pool': roulettePool.join(','),
      'roulette_unique': rouletteUnique ? 1 : 0,
      'roulette_round_unique': rouletteRoundUnique ? 1 : 0,
    };
  }

  factory Tournament.fromMap(Map<String, dynamic> map) {
    final poolStr = map['roulette_pool'] as String? ?? '';
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
      useRoulette: (map['use_roulette'] as int? ?? 0) == 1,
      roulettePool: poolStr.trim().isEmpty ? [] : poolStr.split(','),
      rouletteUnique: (map['roulette_unique'] as int? ?? 1) == 1,
      rouletteRoundUnique: (map['roulette_round_unique'] as int? ?? 1) == 1,
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
    bool? useRoulette,
    List<String>? roulettePool,
    bool? rouletteUnique,
    bool? rouletteRoundUnique,
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
      useRoulette: useRoulette ?? this.useRoulette,
      roulettePool: roulettePool ?? this.roulettePool,
      rouletteUnique: rouletteUnique ?? this.rouletteUnique,
      rouletteRoundUnique: rouletteRoundUnique ?? this.rouletteRoundUnique,
    );
  }
}

