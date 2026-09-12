import 'dart:math';

/// Perturb a Hamiltonian path while retaining adjacency and the spanning prefix.
List<int> weavePath(
  List<int> source,
  int fixedPrefix,
  int turns,
  Random random,
) {
  final path = List<int>.from(source);
  bool adjacent(int a, int b) =>
      (a ~/ 6 - b ~/ 6).abs() <= 1 && (a % 6 - b % 6).abs() <= 1;
  for (var turn = 0; turn < turns; turn++) {
    final a = fixedPrefix + random.nextInt(path.length - fixedPrefix - 1);
    final b = a + 1 + random.nextInt(path.length - a - 1);
    if (!adjacent(path[a - 1], path[b])) continue;
    if (b + 1 < path.length && !adjacent(path[a], path[b + 1])) continue;
    path.setRange(a, b + 1, path.sublist(a, b + 1).reversed);
  }
  return path;
}
