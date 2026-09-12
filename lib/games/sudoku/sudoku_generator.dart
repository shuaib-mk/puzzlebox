import 'dart:math';
import '../../core/services/puzzle_progression.dart';

class SudokuPuzzle {
  final List<int> givens;
  final List<int> solution;
  const SudokuPuzzle(this.givens, this.solution);
}

List<int> candidates(List<int> grid, int cell) {
  final row = cell ~/ 9, col = cell % 9;
  final used = <int>{};
  for (var i = 0; i < 9; i++) {
    used.add(grid[row * 9 + i]);
    used.add(grid[i * 9 + col]);
    used.add(grid[(row ~/ 3 * 3 + i ~/ 3) * 9 + col ~/ 3 * 3 + i % 3]);
  }
  return [
    for (var n = 1; n <= 9; n++)
      if (!used.contains(n)) n,
  ];
}

int countSudokuSolutions(List<int> source, {int limit = 2}) {
  if (source.length != 81 || source.any((n) => n < 0 || n > 9)) return 0;
  final grid = List<int>.from(source);
  for (var i = 0; i < 81; i++) {
    final value = grid[i];
    if (value == 0) continue;
    grid[i] = 0;
    final valid = candidates(grid, i).contains(value);
    grid[i] = value;
    if (!valid) return 0;
  }
  int solve() {
    var cell = -1;
    var options = <int>[];
    for (var i = 0; i < 81; i++) {
      if (grid[i] != 0) continue;
      final c = candidates(grid, i);
      if (c.isEmpty) return 0;
      if (cell == -1 || c.length < options.length) {
        cell = i;
        options = c;
      }
      if (c.length == 1) break;
    }
    if (cell == -1) return 1;
    var count = 0;
    for (final n in options) {
      grid[cell] = n;
      count += solve();
      if (count >= limit) break;
    }
    grid[cell] = 0;
    return count;
  }

  return solve();
}

class SudokuGenerator implements PuzzleGenerator<SudokuPuzzle> {
  @override
  SudokuPuzzle generate(PuzzleRequest request) {
    final rand = Random(request.seed);
    List<int> shuffled() => [0, 1, 2]..shuffle(rand);
    final rows = [
      for (final b in shuffled())
        for (final r in shuffled()) b * 3 + r,
    ];
    final cols = [
      for (final b in shuffled())
        for (final c in shuffled()) b * 3 + c,
    ];
    final digits = List.generate(9, (i) => i + 1)..shuffle(rand);
    final solution = [
      for (final r in rows)
        for (final c in cols) digits[(r * 3 + r ~/ 3 + c) % 9],
    ];
    final grid = List<int>.from(solution);
    final positions = List.generate(81, (i) => i)..shuffle(rand);
    final target = [44, 35, 28][request.difficulty.index];
    var clues = 81;
    for (final cell in positions) {
      final old = grid[cell];
      grid[cell] = 0;
      if (countSudokuSolutions(grid) != 1) {
        grid[cell] = old;
      } else {
        clues--;
      }
      if (clues <= target) break;
    }
    return SudokuPuzzle(grid, solution);
  }

  @override
  bool validate(SudokuPuzzle puzzle) =>
      puzzle.givens.length == 81 &&
      countSudokuSolutions(puzzle.givens) == 1 &&
      List.generate(81, (i) => i).every(
        (i) =>
            puzzle.solution[i] >= 1 &&
            puzzle.solution[i] <= 9 &&
            (puzzle.givens[i] == 0 || puzzle.givens[i] == puzzle.solution[i]),
      );
}

SudokuPuzzle generateSudoku(PuzzleRequest request) =>
    SudokuGenerator().generate(request);
