import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';

enum PuzzleDifficulty { easy, medium, hard }

int stableSeed(String text) {
  var hash = 2166136261;
  for (final unit in text.codeUnits) {
    hash = ((hash ^ unit) * 16777619) & 0x7fffffff;
  }
  return hash;
}

class PuzzleRequest {
  final String game;
  final int seed;
  final PuzzleDifficulty difficulty;
  final int version;
  const PuzzleRequest(
    this.game,
    this.seed,
    this.difficulty, {
    this.version = 1,
  });
  String get id => '$game:$version:${difficulty.name}:$seed';
}

abstract interface class PuzzleGenerator<T> {
  T generate(PuzzleRequest request);
  bool validate(T puzzle);
}

final puzzleProgressionProvider = Provider(
  (ref) => PuzzleProgression(ref.watch(sharedPreferencesProvider)),
);

class PuzzleProgression {
  final SharedPreferences prefs;
  PuzzleProgression(this.prefs);
  int index(String game) => prefs.getInt('progress_v1_$game') ?? 0;
  Future<void> advance(String game) async {
    if (!await prefs.setInt('progress_v1_$game', index(game) + 1)) {
      throw StateError('Could not save progression');
    }
  }

  int seed(String game, {String? progressionKey}) {
    const key = 'installation_puzzle_seed';
    var base = prefs.getInt(key);
    if (base == null) {
      base = DateTime.now().microsecondsSinceEpoch;
      prefs.setInt(key, base);
    }
    return stableSeed('$base:$game:${index(progressionKey ?? game)}');
  }
}
