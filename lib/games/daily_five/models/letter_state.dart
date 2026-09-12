/// The state of a single letter tile on the board.
enum LetterState {
  /// Cell has no letter yet.
  empty,

  /// Cell has a letter typed but row not submitted yet.
  filled,

  /// Letter is in the correct position.
  correct,

  /// Letter is in the word but wrong position.
  present,

  /// Letter is not in the word at all.
  absent,
}
