/// Finds disjoint neighboring-letter paths for every remaining theme word.
/// A player may use an alternative route as long as the board stays solvable.
Map<String, List<int>>? solveStrands(
  List<List<String>> grid,
  List<String> words,
  Set<int> occupied,
) {
  final cols = grid.first.length;
  final letters = grid.expand((r) => r).toList();
  final used = Set<int>.of(occupied);
  final answer = <String, List<int>>{};
  final ordered = List<String>.of(words)
    ..sort((a, b) => b.length.compareTo(a.length));
  bool assign(int wordIndex) {
    if (wordIndex == ordered.length) return true;
    final word = ordered[wordIndex];
    final path = <int>[];
    bool trace(int cell, int letterIndex) {
      if (used.contains(cell) || letters[cell] != word[letterIndex]) {
        return false;
      }
      used.add(cell);
      path.add(cell);
      if (letterIndex == word.length - 1) {
        answer[word] = List<int>.of(path);
        if (assign(wordIndex + 1)) return true;
        answer.remove(word);
      } else {
        final row = cell ~/ cols, col = cell % cols;
        for (var dr = -1; dr <= 1; dr++) {
          for (var dc = -1; dc <= 1; dc++) {
            final nr = row + dr, nc = col + dc;
            if ((dr != 0 || dc != 0) &&
                nr >= 0 &&
                nr < grid.length &&
                nc >= 0 &&
                nc < cols &&
                trace(nr * cols + nc, letterIndex + 1)) {
              return true;
            }
          }
        }
      }
      path.removeLast();
      used.remove(cell);
      return false;
    }

    for (var cell = 0; cell < letters.length; cell++) {
      if (trace(cell, 0)) return true;
    }
    return false;
  }

  return assign(0) ? answer : null;
}
