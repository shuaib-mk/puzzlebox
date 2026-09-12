import 'dart:math';
import '../../games/daily_five/logic/word_list.dart';

/// Centralized random puzzle selection for practice mode across all games.
///
/// Uses a separate seed from daily puzzles to ensure practice puzzles
/// are different from the daily puzzle and vary each session.
abstract final class PracticePuzzleGenerator {
  /// Generates a random seed for practice puzzles.
  ///
  /// Uses current microseconds + a game-specific salt to ensure
  /// different games get different practice puzzles even at the same time.
  static int practiceSeed(String gameSalt) {
    return DateTime.now().microsecondsSinceEpoch ^ gameSalt.hashCode;
  }

  /// Returns a random index from [pool] for practice mode.
  static int randomIndex<T>(List<T> pool, String gameSalt) {
    if (pool.isEmpty) return 0;
    final rand = Random(practiceSeed(gameSalt));
    return rand.nextInt(pool.length);
  }

  /// Returns a random puzzle from [pool] for practice mode.
  static T randomPuzzle<T>(List<T> pool, String gameSalt) {
    return pool[randomIndex(pool, gameSalt)];
  }

  /// Generates a random Daily Five answer for practice mode.
  ///
  /// Uses the valid word list to ensure the answer is a real word.
  static String randomDailyFiveAnswer() {
    final validWords = WordList.answers;
    if (validWords.isEmpty) return 'APPLE';
    final rand = Random(practiceSeed('daily_five'));
    return validWords[rand.nextInt(validWords.length)].toUpperCase();
  }

  /// Generates a random puzzle number for practice mode (for archive access).
  static int randomPuzzleNumber(int maxPuzzle) {
    final rand = Random(practiceSeed('archive'));
    return rand.nextInt(maxPuzzle) + 1;
  }
}
