# Project Context

## What This Project Is

- Product: Android app built by SudarshanTechLabs.
- Users: Google Play users.
- Main platforms: Android first; KMP/iOS only if the repo already supports it.

## Tech Stack

- Language: Kotlin.
- UI: Jetpack Compose.
- Architecture: MVVM with Clean Architecture boundaries.
- State: ViewModel exposes `StateFlow<UiState>`.
- Dependency injection: Hilt unless repo already uses another pattern.
- Persistence: Room and/or DataStore Preferences.
- Serialization: Kotlinx Serialization.
- Networking: Retrofit for Android-only projects; Ktor for KMP projects.
- Build output: AAB for Play Store releases.

## Architecture

- `data`: DTOs, persistence, network clients, repository implementations.
- `domain`: business models, repository interfaces, and one-action use cases.
- `presentation`: Compose screens, UI state, events, and ViewModels.

## Review Priorities

- Correct state handling across recomposition and process death.
- No main-thread database or network work.
- Clear error, empty, and loading states.
- No secrets or signing material committed.
- Accessibility labels for interactive UI.
- Release builds are AAB-oriented and safe for Play Store.

## Commands

- Build:
- Unit tests:
- Instrumented tests:
- Lint:
- Release build:

## Known Risk Areas

- 

## Active Migrations

- 
