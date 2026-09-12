# Design system

Product rule: all games, difficulties and hints are free. No ad interruptions, subscriptions, lives, coins, paywalls or sign-in requirements.

Colors come from Material semantic roles generated from one selected seed. Ocean, Orchard, Clay and Iris each support light and dark surfaces. Use `primary/onPrimary` for selected controls, `surface/onSurface` for ordinary content, `outlineVariant` for quiet borders, and error roles for mistakes. Puzzle-result colors retain consistent meanings across palettes. Do not encode a result by color alone: retain letters, positions, counts and explanatory hints.

Bundled PuzzleSans (Nunito) removes the network dependency for typography. Body text is generally 14–16; game names 18; section labels 22; the home headline 34. Use medium/bold weights intentionally and keep the board visually dominant.

Spacing uses 4, 8, 12, 16, 20 and 24. Controls are approximately 44–48 logical pixels high. Board cells scale to the available area. Small phones use wrapping controls, flexible keys and fitted boards. Content is constrained to 680 pixels on wide displays.

Cards use a 22-pixel radius; primary controls 18; small board squares 3–10 depending on the game. Favor surface contrast and a thin border over heavy decoration.

Selection transitions use 160ms easeOutCubic and honor reduced-motion settings on the updated boards. Mode tabs use 150ms; Daily Five retains its brief tile reveal and invalid-entry shake. Completion feedback lasts roughly 1.4 seconds before advancement (Daily Five allows longer to read a lost answer). Feedback preferences are stored locally. Background touches no longer trigger a click or vibration.

Preserve visibly distinct default, selected, disabled, error and completed states. Avoid invented AI analysis, decorative statistics, promotional deadlines or empty reward systems.

The bright Orchard palette is the default for new installations. Existing appearance preferences are preserved. The original vector puzzle character, generous rounded type, lightly raised cards and distinct game accents create the playful direction without using Duolingo artwork.
