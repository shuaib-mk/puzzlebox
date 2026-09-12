import 'dart:math';
import '../../core/services/puzzle_content.dart';
import '../../core/services/puzzle_progression.dart';

class CrosswordEntry {
  final String answer, clue;
  final int row, col;
  final bool across;
  int number = 0;
  CrosswordEntry(this.answer, this.clue, this.row, this.col, this.across);
  List<int> cells(int size) => List.generate(
    answer.length,
    (i) => (row + (across ? 0 : i)) * size + col + (across ? i : 0),
  );
}

class CrosswordPuzzle {
  final int size;
  final List<String> solution;
  final List<CrosswordEntry> entries;
  CrosswordPuzzle(this.size, this.solution, this.entries);
}

class CrosswordGenerator implements PuzzleGenerator<CrosswordPuzzle> {
  @override
  CrosswordPuzzle generate(PuzzleRequest request) {
    final random = Random(request.seed);
    final mini = request.game == 'mini_crossword';
    final size = mini ? 7 : 11;
    final target = (mini ? 3 : 6) + request.difficulty.index * (mini ? 1 : 2);
    final grid = List.filled(size * size, '#');
    final entries = <CrosswordEntry>[];
    final words = clueBank.keys.where((w) => w.length <= size).toList()
      ..shuffle(random);
    void place(String word, int row, int col, bool across) {
      final entry = CrosswordEntry(word, clueBank[word]!, row, col, across);
      for (var i = 0; i < word.length; i++) {
        grid[entry.cells(size)[i]] = word[i];
      }
      entries.add(entry);
    }

    place(words.removeLast(), size ~/ 2, 0, true);
    bool fits(String word, int row, int col, bool across) {
      if (row < 0 ||
          col < 0 ||
          row + (across ? 1 : word.length) > size ||
          col + (across ? word.length : 1) > size) {
        return false;
      }
      int at(int r, int c) =>
          r < 0 || c < 0 || r >= size || c >= size ? -1 : r * size + c;
      bool occupied(int r, int c) {
        final i = at(r, c);
        return i >= 0 && grid[i] != '#';
      }

      if (occupied(row - (across ? 0 : 1), col - (across ? 1 : 0)) ||
          occupied(
            row + (across ? 0 : word.length),
            col + (across ? word.length : 0),
          )) {
        return false;
      }
      var intersections = 0;
      for (var i = 0; i < word.length; i++) {
        final r = row + (across ? 0 : i), c = col + (across ? i : 0);
        final existing = grid[r * size + c];
        if (existing != '#') {
          if (existing != word[i]) return false;
          if (entries.any(
            (e) => e.across == across && e.cells(size).contains(r * size + c),
          )) {
            return false;
          }
          intersections++;
        } else if (occupied(r + (across ? 1 : 0), c + (across ? 0 : 1)) ||
            occupied(r - (across ? 1 : 0), c - (across ? 0 : 1))) {
          return false;
        }
      }
      return intersections > 0;
    }

    for (var pass = 0; pass < 3 && entries.length < target; pass++) {
      for (final word in List<String>.from(words)) {
        var placed = false;
        final cells = List.generate(grid.length, (i) => i)..shuffle(random);
        for (final cell in cells) {
          if (grid[cell] == '#') continue;
          for (var i = 0; i < word.length && !placed; i++) {
            if (word[i] != grid[cell]) continue;
            for (final across in [true, false]) {
              final row = cell ~/ size - (across ? 0 : i),
                  col = cell % size - (across ? i : 0);
              if (fits(word, row, col, across)) {
                place(word, row, col, across);
                words.remove(word);
                placed = true;
                break;
              }
            }
          }
          if (placed) break;
        }
        if (entries.length >= target) break;
      }
    }
    final starts = entries.map((e) => e.row * size + e.col).toSet().toList()
      ..sort();
    for (final e in entries) {
      e.number = starts.indexOf(e.row * size + e.col) + 1;
    }
    final occupied = grid
        .asMap()
        .entries
        .where((e) => e.value != '#')
        .map((e) => e.key)
        .toList();
    final minRow = occupied.map((i) => i ~/ size).reduce(min);
    final maxRow = occupied.map((i) => i ~/ size).reduce(max);
    final minCol = occupied.map((i) => i % size).reduce(min);
    final maxCol = occupied.map((i) => i % size).reduce(max);
    final cropped = [
      for (var r = minRow; r <= maxRow; r++)
        for (var c = minCol; c <= maxCol; c++) grid[r * size + c],
    ];
    final moved = entries
        .map(
          (e) => CrosswordEntry(
            e.answer,
            e.clue,
            e.row - minRow,
            e.col - minCol,
            e.across,
          )..number = e.number,
        )
        .toList();
    return CrosswordPuzzle(maxCol - minCol + 1, cropped, moved);
  }

  @override
  bool validate(CrosswordPuzzle p) =>
      p.entries.length >= 2 &&
      p.entries.every(
        (e) => e
            .cells(p.size)
            .asMap()
            .entries
            .every((c) => p.solution[c.value] == e.answer[c.key]),
      );
}
