String rulesFor(String title) {
  if (title.contains('Daily Five')) {
    return 'Guess the five-letter word in six tries. Green means the right letter in the right place; amber means it belongs elsewhere. Repeated letters are counted individually. Easy draws words without repeated letters; Hard draws words with repeats. The optional Hard Mode rule makes you reuse revealed clues.';
  }
  if (title.contains('Sudoku')) {
    return 'Fill each row, column and 3×3 box with 1–9 exactly once. Given numbers cannot change. Pencil mode stores candidates; Undo restores your last board and notes. Every generated puzzle has exactly one solution. Difficulty changes the target clue count; it is not a human-solving technique rating.';
  }
  if (title.contains('Connections')) {
    return 'Select four words sharing a category, then Submit. Find all four groups before four mistakes. One away means three selected words belong together. Difficulty changes the category pool, including compound-word groups at harder settings.';
  }
  if (title.contains('Spelling Bee')) {
    return 'Build real words of at least four letters using the seven displayed letters. Every word must use the center letter; letters may repeat. Four-letter words score one point; longer words score their length. A pangram uses all seven letters and earns seven bonus points. Meet the displayed word goal to advance. Only the bundled offline dictionary is accepted.';
  }
  if (title.contains('Crossword') || title.contains('Mini')) {
    return 'Select a clue from the list and type its answer. Tap a crossing twice to change direction. Check marks incorrect filled cells; Hint reveals the selected letter. Undo restores the previous entry. Complete every open cell. These are procedurally generated crisscross grids with original clues.';
  }
  if (title.contains('Strands')) {
    return 'Trace words through neighboring cells, including diagonals. Each cell can be used once, and all cells belong to the theme. Find the spanning theme word as well as the shorter words. Tap an earlier selected cell to shorten the path. Undo releases the last found word. Easy lists target words; Hard hides the theme and uses more winding paths.';
  }
  if (title.contains('Pips')) {
    return 'Place each domino into a slot whose target equals the sum of its two halves. Each domino can be used once. Tap a placed domino to pick it up; placing another domino there returns the old one to the deck. Difficulty increases the number of dominoes. This is a sum-matching domino game.';
  }
  if (title.contains('Tiles')) {
    return 'Match two tiles with the same symbol. Consecutive matches increase your combo; a mismatch resets the combo. Every tile has a matching partner. Difficulty increases the number of pairs. Clear the board to continue.';
  }
  if (title.contains('Letter Boxed')) {
    return 'Make real words by alternating sides of the square. Each word must begin with the last letter of the previous word. Use all twelve letters across your chain. Clear resets the current input; Undo removes the last submitted word. Each box is generated from a verified solution chain. Easy prefills the first suggested word.';
  }
  if (title.contains('Vertex')) {
    return 'Connect pairs of dots so each dot has exactly the number of incident lines printed inside it. Tap a connected pair again to remove its line. Crossings are allowed. Any graph satisfying all counts wins. Hint suggests a route toward one known solution; other solutions may also work.';
  }
  return 'Choose any of the eleven games. Unlimited play has no level cap, ads, payments or accounts. Daily challenges are separate from unlimited totals. Your progress and theme are stored on this device.';
}
