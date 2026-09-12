import '../models/daily_five_state.dart';
import '../models/letter_state.dart';

/// Pure game logic — no Flutter / provider dependencies.
abstract final class DailyFiveLogic {
  /// Evaluates a submitted [guess] against the [answer].
  ///
  /// Returns a list of 5 [TileData] with correct letter states.
  /// Handles duplicate letters correctly (yellow only if remaining count > 0).
  static List<TileData> evaluate(String guess, String answer) {
    assert(guess.length == 5 && answer.length == 5);

    final result = List<TileData>.generate(
      5,
      (i) => TileData(letter: guess[i], state: LetterState.absent),
    );

    // Track remaining unmatched letters in answer
    final answerCounts = <String, int>{};
    for (int i = 0; i < 5; i++) {
      if (guess[i] != answer[i]) {
        answerCounts[answer[i]] = (answerCounts[answer[i]] ?? 0) + 1;
      }
    }

    // First pass: mark greens
    for (int i = 0; i < 5; i++) {
      if (guess[i] == answer[i]) {
        result[i] = TileData(letter: guess[i], state: LetterState.correct);
      }
    }

    // Second pass: mark yellows
    for (int i = 0; i < 5; i++) {
      if (result[i].state == LetterState.correct) continue;
      final ch = guess[i];
      if ((answerCounts[ch] ?? 0) > 0) {
        result[i] = TileData(letter: ch, state: LetterState.present);
        answerCounts[ch] = answerCounts[ch]! - 1;
      }
    }

    return result;
  }

  /// Merges a new row's tile states into the global keyboard key map,
  /// keeping the "best" known state per key (correct > present > absent).
  static Map<String, LetterState> mergeKeyStates(
    Map<String, LetterState> current,
    List<TileData> row,
  ) {
    final updated = Map<String, LetterState>.from(current);
    for (final tile in row) {
      final key = tile.letter.toLowerCase();
      final existing = updated[key];
      updated[key] = _bestState(existing, tile.state);
    }
    return updated;
  }

  static LetterState _bestState(LetterState? existing, LetterState incoming) {
    if (existing == null) return incoming;
    const priority = {
      LetterState.correct: 3,
      LetterState.present: 2,
      LetterState.absent: 1,
      LetterState.filled: 0,
      LetterState.empty: 0,
    };
    return (priority[incoming]! > priority[existing]!) ? incoming : existing;
  }

  /// Builds the emoji share string.
  ///
  /// Example:
  /// ```
  /// Daily Five #124
  /// 🟩🟨⬛⬛⬛
  /// ⬛🟩🟨⬛⬛
  /// 🟩🟩🟩🟩🟩
  /// ```
  static String buildShareString({
    required List<List<TileData>> board,
    required int completedRows,
    required int puzzleNumber,
    required bool won,
    required int maxGuesses,
  }) {
    final rowStrings = <String>[];
    for (int r = 0; r < completedRows; r++) {
      final row = board[r];
      final emojis = row.map((t) {
        switch (t.state) {
          case LetterState.correct:
            return '🟩';
          case LetterState.present:
            return '🟨';
          default:
            return '⬛';
        }
      }).join();
      rowStrings.add(emojis);
    }

    final result = won ? '$completedRows/$maxGuesses' : 'X/$maxGuesses';
    return 'Daily Five #$puzzleNumber $result\n\n${rowStrings.join('\n')}\n\npuzzlebox.app';
  }
}
