# Feature checklist

All eleven games: free unlimited mode; separate Daily mode; persistent difficulty; game-specific free hints; explicit Next; completion feedback; automatic continuation; saved progress; light/dark appearance; four palettes; offline operation.

| Game | Difficulty changes | Core controls / validation |
|---|---|---|
| Daily Five | Distinct-letter vs repeated-letter answer pools | Six guesses, dictionary, duplicate-aware feedback, clue enforcement toggle, position hint, saved board |
| Sudoku | Clue-count targets with uniqueness checks | Notes, note-aware undo, erase, conflicts, timer, logical single hint or clearly labeled solution reveal |
| Connections | Direct vs compound-word category pools | Unique displayed terms, four-word submit, four mistakes, one-away, shuffle/deselect, useful category hint |
| Spelling Bee | Generated letter set and word goal | Guaranteed pangram, actual dictionary, center letter, minimum length, duplicate rejection, score and bonus |
| Mini | Entry-count target; Easy starting letters | Consistent crossings, every clue available, direction, undo, check, letter reveal, timer |
| Crossword | Larger entry-count target; Easy starting letters | Same complete control set as Mini; cropped playable layout |
| Strands | Word visibility and path winding | All cells covered, spanning theme word, adjacency, no cell reuse, selected-path hints, undo found word |
| Pips | Four / six / eight dominoes | Exact sum constraints, each piece once, pickup/replacement, undo, target hint |
| Tiles | Four / six / nine pairs | Guaranteed partners, combo scoring, match hint, fresh rounds |
| Letter Boxed | Easy first-word assistance; Hard longer solution chain | Real words, side alternation, linked starts, twelve-letter coverage, clear/undo, known solution |
| Vertex | Four / six / eight nodes and extra edges | Degree validation, add/remove edges, undo, known-solution route hint |

## Regression coverage

Release validation: 39 tests passed; Dart analyzer reported no issues.

- 90 Sudoku seeds across difficulties: unique solutions, row/column validity, reproducibility, and distinct clue budgets.
- 600 generated crossword boards: clue consistency at every crossing and unique entries.
- 120 Letter Boxed chains: actual dictionary membership, full coverage, word linkage, alternating sides.
- 200 winding Strands paths: coverage, adjacency, and preserved spanning prefix.
- All eleven screens load and advance at 390×844 and 320×700.
- Saved sequence seeds, idempotent completion totals, legacy-count migration, daily deduplication, streak gaps, and Daily Five loss/resume.
- A Pips completion exercises counting and automatic transition through the UI.
- Visual review of the home screen in all four palettes and representative game screens.

The release is built and APK-signature verified. No physical Android device or configured emulator was available during this run, so physical-device installation, platform sound/haptics, and manufacturer-specific behavior are not claimed as tested.

## Prototype issues addressed

Practice controls no longer disappear behind Next. Daily Five losses no longer count as solved puzzles. Letter Boxed rejects made-up words and requires word chaining. Spelling Bee rejects arbitrary strings and generates a reachable goal. Pips requires target sums rather than merely filling slots. Strands enforces adjacency and prevents duplicate completion. Crosswords no longer overwrite conflicting clue answers. Difficulty selectors affect the puzzle. Next advances the sequence. Timers and delayed transitions are disposed safely. Light mode and theme selections apply across games.

Hardcoded fake leaderboard scores, simulated hint feeds, and the nonfunctional archive/badge navigation were removed rather than represented as real services. No remote leaderboard or account synchronization is included.
