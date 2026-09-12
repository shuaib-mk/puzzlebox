import 'package:flutter_test/flutter_test.dart';
import 'package:puzzlebox/games/daily_five/logic/daily_five_logic.dart';
import 'package:puzzlebox/games/daily_five/models/daily_five_state.dart';
import 'package:puzzlebox/games/daily_five/models/letter_state.dart';

void main() {
  group('DailyFiveLogic - Guess Evaluation', () {
    test('All letters correct', () {
      final res = DailyFiveLogic.evaluate('APPLE', 'APPLE');
      expect(res.every((t) => t.state == LetterState.correct), isTrue);
    });

    test('All letters absent', () {
      final res = DailyFiveLogic.evaluate('ZZZZZ', 'APPLE');
      expect(res.every((t) => t.state == LetterState.absent), isTrue);
    });

    test('Handles duplicate letters in guess vs single in answer', () {
      // Answer has one P. Guess has two P's.
      // Index 1 (P) is correct. Index 2 (P) should be absent, NOT present.
      final res = DailyFiveLogic.evaluate('SPEAR', 'PAPER');
      // P A P E R
      // S P E A R -> S:absent, P:present, E:present, A:present, R:correct
      expect(res[0].state, LetterState.absent); // S
      expect(res[1].state, LetterState.present); // P (matches one P in PAPER)
      expect(res[2].state, LetterState.present); // E
      expect(res[3].state, LetterState.present); // A
      expect(res[4].state, LetterState.correct); // R
    });

    test('Handles duplicate letter green override yellow', () {
      final res = DailyFiveLogic.evaluate('POPUP', 'PAPER');
      // P A P E R
      // P O P U P -> P(0):correct, O:absent, P(2):correct, U:absent, P(4):absent (no 3rd P)
      expect(res[0].state, LetterState.correct);
      expect(res[1].state, LetterState.absent);
      expect(res[2].state, LetterState.correct);
      expect(res[3].state, LetterState.absent);
      expect(res[4].state, LetterState.absent);
    });
  });

  group('DailyFiveLogic - Share String', () {
    test('Formats win emoji grid correctly', () {
      final mockBoard = <List<TileData>>[
        [
          const TileData(letter: 'S', state: LetterState.absent),
          const TileData(letter: 'T', state: LetterState.present),
          const TileData(letter: 'A', state: LetterState.correct),
          const TileData(letter: 'R', state: LetterState.absent),
          const TileData(letter: 'T', state: LetterState.absent),
        ],
        [
          const TileData(letter: 'A', state: LetterState.correct),
          const TileData(letter: 'P', state: LetterState.correct),
          const TileData(letter: 'P', state: LetterState.correct),
          const TileData(letter: 'L', state: LetterState.correct),
          const TileData(letter: 'E', state: LetterState.correct),
        ],
      ];

      final shareStr = DailyFiveLogic.buildShareString(
        board: mockBoard,
        completedRows: 2,
        puzzleNumber: 42,
        won: true,
        maxGuesses: 6,
      );

      expect(shareStr, contains('Daily Five #42 2/6'));
      expect(shareStr, contains('⬛🟨🟩⬛⬛'));
      expect(shareStr, contains('🟩🟩🟩🟩🟩'));
      expect(shareStr, contains('puzzlebox.app'));
    });
  });
}
