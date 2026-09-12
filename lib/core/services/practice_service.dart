import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';

final practiceServiceProvider = Provider<PracticeService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PracticeService(prefs);
});

/// Reads and writes per-game practice statistics to SharedPreferences.
///
/// Keys are namespaced by [gameType], e.g. "daily_five_practice".
class PracticeService {
  final SharedPreferences _prefs;

  PracticeService(this._prefs);

  static String _key(String gameType) => '${gameType}_practice';

  /// Returns the number of practice puzzles solved for this game type.
  int getSolvedCount(String gameType) {
    final raw = _prefs.getString('solved_v2_$gameType');
    if (raw != null) {
      try {
        return (jsonDecode(raw) as Map)['count'] as int;
      } catch (_) {}
    }
    return _prefs.getInt(_key(gameType)) ?? 0;
  }

  /// Increments and returns the new solved count.
  Future<int> incrementSolvedCount(String gameType) async {
    final current = getSolvedCount(gameType);
    final next = current + 1;
    await _prefs.setInt(_key(gameType), next);
    return next;
  }

  Future<int> recordSolved(String gameType, String puzzleId) async {
    final key = 'solved_v2_$gameType';
    final raw = _prefs.getString(key);
    if (raw != null) {
      try {
        if ((jsonDecode(raw) as Map)['id'] == puzzleId) {
          return getSolvedCount(gameType);
        }
      } catch (_) {}
    }
    final next = getSolvedCount(gameType) + 1;
    if (!await _prefs.setString(
      key,
      jsonEncode({'id': puzzleId, 'count': next}),
    )) {
      throw StateError('Save failed');
    }
    return next;
  }

  /// Resets the practice solved count for this game type.
  Future<void> resetSolvedCount(String gameType) async {
    await _prefs.remove(_key(gameType));
    await _prefs.remove('solved_v2_$gameType');
  }
}
