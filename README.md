# In-Class Activity 15: API-to-Cloud Trivia Showdown

This Flutter app turns five live trivia questions into a short quiz with instant answer feedback, a final score, and a simulated score sync. It builds on the instructor's `starter_code.dart` for [Activity 15](https://codd.cs.gsu.edu/~lhenry23/mad/ica/act15/index.html).

Repository: [Prophet-20/In-Class-Activity-15](https://github.com/Prophet-20/In-Class-Activity-15)

## Running the app

Open a terminal in the project folder and run:

```bash
flutter pub get
flutter run
```

To try it in Safari, run `flutter run -d web-server`, then open the local URL that Flutter prints.

## How the quiz works

The app requests five easy, multiple-choice general-knowledge questions from Open Trivia Database. It checks for HTTP status `200` and an API `response_code` of `0` before using the response. It also checks that the response contains exactly five questions.

Each JSON record becomes a `Question` object. The correct and incorrect answers are combined and shuffled, and encoded text such as `&quot;`, `&#039;`, and `&amp;` is cleaned up before it appears on screen.

While the request is running, the app shows a loading indicator. If something goes wrong, it shows an error and a **Try Again** button. Once the questions arrive, the screen shows the question number, progress through the round, and the answer choices.

You get one answer per question. The correct answer turns green, and an incorrect selection turns red. Extra taps cannot change the answer or add points. After all five questions, the app shows the final score and offers **Play Again**, which clears the previous round's state and loads another set of questions.

Long questions and results can scroll on smaller screens. The project also includes Android's internet permission and the macOS entitlements needed for outgoing network requests.

## What the score sync does

The assignment allows a classroom simulation when no backend endpoint is provided, so this app uses that option. The activity page did not supply an instructor endpoint.

The simulated sync waits one second, then shows a JSON payload containing the score, total question count, and a UTC timestamp. The button and confirmation message clearly label it as a simulation. It does not send an HTTP write or save the score online.

## API bridge debrief

Fetching trivia starts with a GET request to a public REST endpoint. There are two results to check: the HTTP status tells us whether the request succeeded at the HTTP level, while `response_code` tells us whether the trivia API returned a successful result. Checking both helps keep an unsuccessful response from becoming quiz content.

JSON decoding turns the response text into Dart values. From there, `Question.fromJson` gives the screen readable question and answer properties, along with shuffled choices.

Because a network request takes time and can fail, the interface handles loading, ready, and error states separately. Selecting an answer updates local state: the chosen option, the feedback colors, and the score. A guard prevents repeated taps from adding points. A round identifier also keeps an unfinished operation from an older round from changing a new round.

These same ideas carry into REST writes in Activity 16. A real score submission would need the instructor's endpoint and payload format, an appropriate HTTP method, JSON serialization, and a response confirming that the backend accepted the write. The screen would then need to report success or failure based on that response. Waiting briefly and changing a label, as this simulation does, cannot confirm that data was saved remotely.

Activity 14's lessons about service boundaries, asynchronous work, validating incoming data, and checking observed behavior still apply here. Firebase messaging permissions, device registration tokens, and FCM lifecycle handlers are outside this assignment's scope.

## Critical thinking: undergraduate prompts

### What happens if connectivity drops after questions have loaded?

The player should be able to finish the current round. All five questions and their answers are already in `_questions`, so choosing answers and advancing through the quiz do not need another network request. In this implementation, those actions keep working even if the connection disappears. The app does not monitor connectivity or show an offline banner, so it would be misleading to claim that it does.

The loading state belongs to a request that is still in progress. A lost connection before that request finishes leads to an error or a timeout, followed by **Try Again**. Once a round is loaded, the app should keep showing the questions instead of replacing them with an error just because the network is unavailable. Simulated sync also works locally; its confirmation still does not mean anything was saved online.

**Play Again** currently clears the completed round and requests five new questions. Without connectivity, that request fails and the error screen appears. As a future improvement, the app could offer a clearly labeled replay of the already loaded questions when a fresh request fails. That would preserve something useful to play while making it clear that the questions are not new. This fallback is a design proposal, not implemented behavior.

### What would be useful to save locally?

A personal best score would be a useful small addition. Right now, closing or restarting the app loses the previous result. Saving the best score with its total question count and quiz settings would give the player a goal for the next comparable round. It could live in a small local preferences record rather than a database, since it is only a few values. Saving the settings matters: a score from a different difficulty or number of questions should not silently replace the comparison for this five-question easy quiz.

The screen should call it **Personal best on this device**. Local storage would not make it a shared leaderboard because it would not send results to a common server, identify other players, or compare results across devices. It can also be cleared or modified locally, so it would not be trustworthy as a competitive ranking. A useful test would finish a round, restart the app, and check that the best score returns with the device-only label and matching quiz settings. Local persistence is discussed here as a design choice; it has not been added to the app.

## Development notes

The project starts from the instructor's `starter_code.dart`. The completed version adds retry and error reset, validates the five-question result count, keeps question and result content scrollable, displays the simulated JSON payload, and clears the old sync notification on replay. The HTTP client can be injected for tests. Network declarations are included for Android and macOS.

The evidence update adds captions, these prompt responses, and a test that captures loading and an HTTP failure. It does not change the quiz implementation or add local storage.

## Testing and submission

[EVIDENCE.md](EVIDENCE.md) walks through the labeled screenshots. [VALIDATION.md](VALIDATION.md) explains the checks and their limits. [SUBMISSION_DRAFT.md](SUBMISSION_DRAFT.md) contains a summary ready to review before pasting into the LMS.

The source and evidence are prepared for the repository linked above. No LMS submission has been made. The activity page does not require an APK or a separate reflection document unless the instructor or LMS asks for one.
