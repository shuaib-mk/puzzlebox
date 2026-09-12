import 'package:flutter/services.dart';

/// Loads and exposes the bundled word lists.
class WordList {
  WordList._();

  static List<String>? _answers;
  static List<String>? _validGuesses;

  /// Load both word lists from assets. Call once at app start.
  static Future<void> init() async {
    final answersRaw = await rootBundle.loadString(
      'assets/words/daily_five_answers.txt',
    );
    final validRaw = await rootBundle.loadString(
      'assets/words/daily_five_valid.txt',
    );

    _answers = answersRaw
        .split('\n')
        .map((w) => w.trim().toUpperCase())
        .where((w) => w.length == 5)
        .toList();

    final validSet = validRaw
        .split('\n')
        .map((w) => w.trim().toUpperCase())
        .where((w) => w.length == 5)
        .toSet();

    // Ensure all answers are in the valid set
    for (final a in _answers!) {
      validSet.add(a);
    }
    _validGuesses = validSet.toList();
  }

  static List<String> get answers {
    assert(_answers != null, 'WordList.init() must be called before use');
    return _answers!;
  }

  static bool isValidGuess(String word) {
    assert(_validGuesses != null, 'WordList.init() must be called before use');
    return _validGuesses!.contains(word.toUpperCase());
  }

  /// Picks today's answer deterministically using the puzzle number.
  static String answerForPuzzle(int puzzleNumber) {
    final list = answers;
    return list[puzzleNumber % list.length];
  }
}
