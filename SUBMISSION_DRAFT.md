# LMS summary draft

Repository: https://github.com/Prophet-20/In-Class-Activity-15

This Flutter project fetches five live Open Trivia Database questions, checks the HTTP status and API response code, maps JSON into question objects, and cleans encoded question and answer text. It shows loading and error states, shuffled answers, green/red feedback, one-answer scoring, round progression, a final score, and replay.

The score action is the assignment's permitted classroom simulation. It displays a JSON payload and simulation confirmation. No backend request is sent and no score is saved online.

The repository includes `EVIDENCE.md` and 11 labeled screenshots covering a complete live five-question round in Safari, answer feedback, a 4/5 result, simulation confirmation and payload, replay, and controlled loading/error states. The loading and HTTP 503 screenshots are explicitly labeled as widget-test captures. `README.md` includes setup instructions, the API bridge debrief, and responses to both undergraduate critical-thinking prompts about connectivity and local storage. No local-storage implementation was added.

Validation: Flutter analysis reported no issues; all ten tests passed; the release web build succeeded. Native Android, iOS, and macOS builds have not been run.

This is a draft for review. No LMS submission has been made. Check any additional course LMS attachment instructions before submitting.
