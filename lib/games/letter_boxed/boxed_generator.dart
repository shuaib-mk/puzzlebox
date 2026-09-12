import 'dart:math';

class BoxedPuzzle {
  final List<List<String>> sides;
  final List<String> solution;
  BoxedPuzzle(this.sides, this.solution);
}

/// Build a legal word chain first, then color its adjacency graph into sides.
BoxedPuzzle generateBoxed(List<String> dictionary, int seed, int wordCount) {
  final random = Random(seed);
  final words =
      dictionary
          .where(
            (w) =>
                w.length >= 4 && w.length <= 7 && !RegExp(r'(.)\1').hasMatch(w),
          )
          .toSet()
          .toList()
        ..sort();
  final byFirst = <String, List<String>>{};
  for (final w in words) {
    (byFirst[w[0]] ??= []).add(w);
  }
  for (var attempt = 0; attempt < 4000; attempt++) {
    final chain = <String>[words[random.nextInt(words.length)]];
    while (chain.length < wordCount) {
      final next = (byFirst[chain.last[chain.last.length - 1]] ?? [])
          .where((w) => !chain.contains(w))
          .toList();
      if (next.isEmpty) break;
      chain.add(next[random.nextInt(next.length)]);
    }
    if (chain.length != wordCount) continue;
    final letters = chain.join().split('').toSet().toList();
    if (letters.length != 12) continue;
    final edges = <String, Set<String>>{for (final c in letters) c: {}};
    for (final w in chain) {
      for (var i = 1; i < w.length; i++) {
        edges[w[i]]!.add(w[i - 1]);
        edges[w[i - 1]]!.add(w[i]);
      }
    }
    letters.sort((a, b) => edges[b]!.length.compareTo(edges[a]!.length));
    final sides = List.generate(4, (_) => <String>[]);
    bool color(int i) {
      if (i == letters.length) return true;
      final order = [0, 1, 2, 3]..shuffle(random);
      for (final side in order) {
        if (sides[side].length == 3 ||
            sides[side].any(edges[letters[i]]!.contains)) {
          continue;
        }
        sides[side].add(letters[i]);
        if (color(i + 1)) return true;
        sides[side].removeLast();
      }
      return false;
    }

    if (color(0)) {
      for (final side in sides) {
        side.shuffle(random);
      }
      return BoxedPuzzle(sides, chain);
    }
  }
  throw StateError('No legal letter box found for this seed');
}
