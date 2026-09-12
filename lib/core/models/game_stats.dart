/// Shared stats model used across all games.
class GameStats {
  final int gamesPlayed;
  final int gamesWon;
  final int currentStreak;
  final int maxStreak;
  final Map<int, int> distribution; // guess number → count

  const GameStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.distribution = const {},
  });

  double get winPercentage =>
      gamesPlayed == 0 ? 0 : (gamesWon / gamesPlayed * 100);

  GameStats copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? currentStreak,
    int? maxStreak,
    Map<int, int>? distribution,
  }) {
    return GameStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      distribution: distribution ?? this.distribution,
    );
  }

  Map<String, dynamic> toJson() => {
    'gamesPlayed': gamesPlayed,
    'gamesWon': gamesWon,
    'currentStreak': currentStreak,
    'maxStreak': maxStreak,
    'distribution': distribution.map((k, v) => MapEntry(k.toString(), v)),
  };

  factory GameStats.fromJson(Map<String, dynamic> json) {
    final rawDist = json['distribution'] as Map<String, dynamic>? ?? {};
    return GameStats(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      maxStreak: json['maxStreak'] as int? ?? 0,
      distribution: rawDist.map((k, v) => MapEntry(int.parse(k), v as int)),
    );
  }
}
