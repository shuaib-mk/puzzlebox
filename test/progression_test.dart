import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puzzlebox/core/providers/settings_provider.dart';
import 'package:puzzlebox/core/services/practice_service.dart';
import 'package:puzzlebox/core/services/stats_service.dart' as stats;
import 'package:puzzlebox/core/services/puzzle_progression.dart';
import 'package:puzzlebox/core/services/puzzle_content.dart';
import 'package:puzzlebox/core/widgets/game_mode_toggle.dart';
import 'package:puzzlebox/games/daily_five/providers/daily_five_provider.dart';
import 'package:puzzlebox/games/daily_five/logic/word_list.dart';
import 'package:puzzlebox/games/daily_five/models/daily_five_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  test(
    'Daily Five retains typed input, wins once, and serializes Next',
    () async {
      await WordList.init();
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      final provider = dailyFiveProvider(GameMode.practice);
      final notifier = container.read(provider.notifier);
      final answer = container.read(provider).answer;
      notifier.addLetter(answer[0]);
      final restored = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(restored.dispose);
      expect(restored.read(provider).currentInput, [answer[0]]);
      for (final c in answer.substring(1).split('')) {
        notifier.addLetter(c);
      }
      await notifier.submitGuess();
      expect(container.read(provider).phase, GamePhase.won);
      expect(PracticeService(prefs).getSolvedCount('daily_five'), 1);
      await Future.wait([notifier.nextPuzzle(), notifier.nextPuzzle()]);
      expect(PuzzleProgression(prefs).index('daily_five'), 1);
      expect(container.read(provider).phase, GamePhase.playing);
      expect(WordList.isValidGuess('CRANE'), isTrue);
      expect(WordList.isValidGuess('ZZZZZ'), isFalse);
    },
  );
  test('Completion is idempotent and preserves legacy totals', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sudoku_practice', 7);
    final service = PracticeService(prefs);
    await Future.wait([
      service.recordSolved('sudoku', 'p1'),
      service.recordSolved('sudoku', 'p1'),
    ]);
    expect(service.getSolvedCount('sudoku'), 8);
    expect(PracticeService(prefs).getSolvedCount('sudoku'), 8);
    await service.recordSolved('sudoku', 'p2');
    expect(service.getSolvedCount('sudoku'), 9);
  });
  test('Progression persists seeds and separates games', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = PuzzleProgression(prefs);
    final first = service.seed('sudoku');
    expect(PuzzleProgression(prefs).seed('sudoku'), first);
    expect(service.seed('tiles'), isNot(first));
    await service.advance('sudoku');
    expect(service.seed('sudoku'), isNot(first));
  });
  test('Daily stats count once and reset streak after missed day', () async {
    final service = stats.StatsService(await SharedPreferences.getInstance());
    await service.recordResult(
      gameType: 'sudoku',
      todayKey: '2026-09-01',
      won: true,
    );
    await service.recordResult(
      gameType: 'sudoku',
      todayKey: '2026-09-01',
      won: true,
    );
    expect(service.loadStats('sudoku').gamesPlayed, 1);
    await service.recordResult(
      gameType: 'sudoku',
      todayKey: '2026-09-02',
      won: true,
    );
    expect(service.loadStats('sudoku').currentStreak, 2);
    await service.recordResult(
      gameType: 'sudoku',
      todayKey: '2026-09-04',
      won: true,
    );
    expect(service.loadStats('sudoku').currentStreak, 1);
  });
  test('Bee bases each contain exactly seven distinct letters', () {
    for (final w in beePangrams) {
      expect(w.split('').toSet().length, 7, reason: w);
    }
  });
  test(
    'Losing Daily Five does not increment solved count; board resumes',
    () async {
      await WordList.init();
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      final provider = dailyFiveProvider(GameMode.practice);
      final notifier = container.read(provider.notifier);
      final answer = container.read(provider).answer;
      final wrong = WordList.answers.firstWhere((w) => w != answer);
      for (var i = 0; i < 6; i++) {
        for (final c in wrong.split('')) {
          notifier.addLetter(c);
        }
        await notifier.submitGuess();
      }
      expect(container.read(provider).phase, GamePhase.lost);
      expect(PracticeService(prefs).getSolvedCount('daily_five'), 0);
      final restored = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(restored.dispose);
      expect(restored.read(provider).answer, answer);
      expect(restored.read(provider).phase, GamePhase.lost);
      await notifier.nextPuzzle();
      expect(container.read(provider).phase, GamePhase.playing);
      expect(container.read(provider).currentRow, 0);
    },
  );
}
