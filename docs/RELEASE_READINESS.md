# Release readiness — 2.1.0

This is a tested release candidate, not a claim of zero defects or Google Play approval.

## Verification in this revision

- Automated full solve-and-next playthroughs for Sudoku, Connections, Bee, Mini, Crossword, Strands, Tiles, Letter Boxed, Vertex and Pips.
- Daily Five win/loss, duplicate-letter evaluation, typed-input restoration and repeated Next regression checks.
- Independent difficulty saves and repeated Next regression checks across the shared session controller.
- Seeded generation tests and compact-phone screen loading checks.
- Final source analysis: no issues. Full automated suite: 51 tests passed.
- Signed APK and AAB built with version 2.1.0 (code 3). APK signature and 16 KB ZIP alignment pass. All arm64/x86_64 native-library LOAD segments have at least 16 KB alignment.
- Android 16 emulator: signed APK installed and cold-launched; home and Sudoku rendered at 390 x 844; no Puzzlebox AndroidRuntime/Flutter errors in the inspected log. The resource-constrained emulator showed a System UI timeout during startup, so this run does not establish real-device performance. Physical-device and broad accessibility checks remain open.

## Owner steps before public Google Play release

1. Complete developer account verification and create the app in Play Console.
2. Enrol the app in Play App Signing and upload the signed Android App Bundle. Keep the private upload key backed up securely; it is intentionally absent from GitHub.
3. Complete Data safety, content rating, target audience and ads declarations based on the actual build. The app has no accounts, ads, analytics or developer-operated cloud backend.
4. Publish the privacy notice at a publicly accessible web URL and enter it in Play Console. The same notice is accessible inside the app. Add the owner's verified support contact to the listing.
5. Upload store icon, feature graphic and genuine phone screenshots, then review Play's pre-launch report and test on physical low-end and recent devices, including accessibility and large text.
6. If the account falls under the new-personal-account requirement, complete the required closed test: at least 12 continuously opted-in testers for 14 days, then apply for production access.

## Product scope still requiring editorial/UX review

Pips is a domino sum-placement variant, Tiles is a matching-pairs variant, Vertex is a degree-connection puzzle, and crosswords use procedurally crossed words. They do not reproduce NYT's complete mechanics or editorial puzzle standards. Word/category banks are finite even though boards can be regenerated indefinitely. The broader accepted-word dictionary includes uncommon words; generated answers remain curated. Automated playthroughs establish that the implemented rules can be played to completion, not that every puzzle is editorially excellent.

## Official requirements checked

- Target API: https://developer.android.com/google/play/requirements/target-sdk
- 16 KB page sizes: https://developer.android.com/guide/practices/page-sizes
- Closed testing: https://support.google.com/googleplay/android-developer/answer/14151465
- Data safety and privacy: https://support.google.com/googleplay/android-developer/answer/10787469
