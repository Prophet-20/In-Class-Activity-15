# In-Class Activity 15: Trivia Showdown

A Flutter quiz that fetches five live questions, gives instant answer feedback, and shows a final score with a simulated sync.

## Run it

With Flutter installed, open a terminal in the project folder:

```bash
flutter pub get
flutter run
```

For Safari, run `flutter run -d web-server` and open the local URL it prints.

## What it does

- Fetches five easy, multiple-choice general-knowledge questions from Open Trivia Database. Checks HTTP `200`, API `response_code == 0`, and the question count before starting.
- Maps JSON into `Question` objects, shuffles answer choices, and cleans `&quot;`, `&#039;`, and `&amp;`.
- Shows loading, readable errors with **Try Again**, question numbers, and progress.
- Accepts one answer per question: the correct choice turns green, an incorrect selection turns red, and extra taps cannot add points.
- Shows the score out of five and offers **Play Again**. Questions and results scroll on smaller screens.

**Score sync is a simulation.** No instructor endpoint was provided. The action waits one second and displays JSON containing the score, total questions, and a UTC timestamp. It sends no backend request and saves nothing online.

## API bridge and development notes

GET retrieves the questions. HTTP status checks and the API response code answer different questions: whether the HTTP request succeeded and whether the trivia service returned usable results. JSON mapping then supplies the UI, while local state controls feedback and scoring. A round identifier prevents an older asynchronous operation from changing a new round.

For Activity 16, a real score write would need an agreed endpoint, an appropriate method such as POST, a JSON payload, and a backend response that determines success or failure. The validation and asynchronous-state habits from Activity 14 carry over; FCM handlers, notification permissions, and device tokens are outside this activity.

Changes to the starter include retry/error reset, five-question validation, scrolling, a visible simulation payload, and clearing old sync notifications on replay. An injectable HTTP client supports testing. Android internet permission and macOS outgoing-network entitlements are included.

## Tests and evidence

`flutter analyze` reports no issues, all **10 tests pass**, and the release web build succeeds. Native Android, iOS, and macOS builds have not been run.

- [Evidence](EVIDENCE.md): 11 labeled screenshots, including a full live Safari round and clearly identified controlled loading/error captures.
- [Validation](VALIDATION.md): checks, reproduction details, and limitations.
- [LMS summary draft](SUBMISSION_DRAFT.md): ready to review before submission.

No LMS submission has been made. The activity page does not require an APK or separate reflection document unless the instructor or LMS asks for one.
