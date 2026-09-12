# Architecture

`PuzzleRequest` carries game ID, stable seed, difficulty, and generator version. `PuzzleGenerator<T>` defines generation and validation for typed engines such as Sudoku and Crossword. Other existing screens retain their local generation adapters rather than being rewritten merely to conform to a type.

`puzzleProgressionProvider` exposes the shared local progression repository. Seeds use an explicit stable hash, not runtime string hash codes. The installation seed plus per-game index yields a repeatable unlimited sequence. Daily seeds use the game/date/difficulty.

`PracticeModeMixin` adapts existing ConsumerState screens to shared mode controls, difficulty settings, next-puzzle handling, completion feedback, progression, and saved-session storage. Daily Five retains its existing Riverpod notifier, using the same progression and solved-count services.

Each screen provides `captureProgress` and `restoreProgress` for game-specific data. Saves include the request identity and mode, are written every second and on normal disposal, and restore only to the matching puzzle. This is local best-effort persistence; SharedPreferences is not a transactional cloud database. A sudden process kill may lose the last second of input. Future server synchronization belongs behind the repository boundary.

Completion is guarded per loaded session. Unlimited solved counts use a puzzle-identity ledger to avoid duplicate counts. The next index is reserved before the automatic transition so leaving during the success animation does not reset the sequence. Request generations and mounted checks reject stale asynchronous callbacks. Next cancels pending transitions. Daily statistics are recorded separately, once per date, with missed-day streak resets.

Sudoku and Letter Boxed generation run in a compute isolate. Sudoku removes clues only while exactly one solution remains. Letter Boxed builds a real-word chain before assigning letters to four valid sides. Crossword only places words when all crossings agree and neighboring cells remain legal. Strands preserves a spanning prefix and changes the remaining full-coverage path with adjacency-preserving reversals. Spelling Bee starts from a seven-distinct-letter word, guaranteeing a pangram.

Current content boundaries: the crossword bank and thematic word sets are finite, curated local content. They can be expanded without replacing progression or the UI. The app does not claim editorial-level ambiguity grading for Connections or human-technique Sudoku ratings.
