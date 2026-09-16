class ChessPuzzle {
  final String id;
  final String title;
  final String fen;
  final List<String> solutionMoves; // SAN strings e.g. ['Qxf7#']
  final String description;
  final String difficulty;
  final String hint;

  const ChessPuzzle({
    required this.id,
    required this.title,
    required this.fen,
    required this.solutionMoves,
    required this.description,
    required this.difficulty,
    required this.hint,
  });
}
