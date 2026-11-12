# Testing notes

The app was checked on November 11, 2026, using Flutter 3.47.3 and Dart 3.13.3 on macOS.

## Automated checks

All three checks completed successfully:

- `flutter analyze` reported no issues.
- `flutter test` passed all ten tests.
- `flutter build web --no-pub` produced a release web build.

The tests cover the main quiz flow: showing the loading state, requesting the right parameters, cleaning encoded text, and displaying green and red answer feedback. They also check that repeated taps cannot increase the score, that a round with three correct answers ends at **3 / 5**, and that replay resets the round.

For the score simulation, the tests check the JSON payload and confirm that it makes no HTTP write. Error cases cover HTTP failures and recovery through retry, API error codes, empty results, malformed JSON, and a request timeout. A smaller-screen check uses a **375 × 550 logical-pixel viewport** to make sure the question content can scroll without overflowing.

These widget tests use mocked HTTP responses so the expected results stay predictable. The live network check is described below.

The tenth test captures the real loading and HTTP 503 error screens with controlled HTTP responses. The screenshots and their captions are in [EVIDENCE.md](EVIDENCE.md).

## Trying the app in Safari

The release web build was opened in Safari at a localhost-only address. It fetched five live questions from Open Trivia Database and completed a full round, ending with **Final Score: 4 / 5**.

The delivery-evidence run included questions about the first chocolate bar, Black Forest Gateau, a dartboard, languages in Switzerland, and vodka. The first answer was intentionally incorrect, followed by four correct answers. Trying to correct the first answer with a second tap did not change the selection or award an extra point. Screenshots 01–07 show that round and its final 4/5 result.

The simulated score action displayed its completion message and JSON payload, including score `4` and total `5`. No score was written to a backend. Screenshot 08 shows that confirmation. Play Again loaded a different first question; screenshot 09 shows the restarted round.

## What has not been checked

Android, iOS, and macOS native builds have not been run. The Android internet permission and macOS outgoing-network entitlements are included, but native platform behavior still needs to be checked on those targets.

There is no real cloud integration in this version. The assignment permits a simulation, and no instructor endpoint was supplied on the activity page.

## Submission status

The project and evidence are prepared for the GitHub repository linked in the README. No LMS submission has been made and no real score has been submitted. The LMS submission remains pending approval.
