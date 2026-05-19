# Android Review Prompt

Review Android, Kotlin, Kotlin Multiplatform, Jetpack Compose, Room, Hilt, Gradle, and Play Store release changes.

## Instructions

1. Inspect repo state, changed files, Gradle files, manifests, source, and tests.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, README, and nearby architecture patterns.
3. Focus on Android-specific correctness, lifecycle safety, UI behavior, release risk, and tests.
4. Do not edit, push, publish, or change repo settings unless explicitly asked.

## Checklist

- Compose state hoisting, stability, recomposition safety.
- ViewModel `StateFlow<UiState>` and event handling.
- Coroutine scopes, dispatchers, cancellation, and main-thread safety.
- Room migrations and database work off the main thread.
- Hilt scopes and duplicate bindings.
- Navigation arguments and back behavior.
- Accessibility labels, touch targets, readable text, dark mode.
- No secrets, keystores, signing material, sensitive logs, or unsafe exported components.
- AAB-oriented release behavior where relevant.

## Output

Lead with severity-ranked findings and verification notes.
