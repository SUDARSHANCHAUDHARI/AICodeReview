# Project Context

Use this file to give Codex stable project knowledge before reviews, audits, fixes, or explanations.

Do not include secrets, private keys, signing material, `.env` values, customer data, or anything that should not be committed.

## What This Project Is

- Product:
- Users:
- Main platforms:
- Current status:

## Tech Stack

- Language:
- Frameworks:
- Build system:
- Persistence:
- Networking:
- Dependency injection:
- Serialization:
- Testing:

## Architecture

Describe the major layers and what each owns.

Example:

- `data`: API/database implementations and DTO mapping.
- `domain`: business models, repository interfaces, and use cases.
- `presentation`: UI state, ViewModels, screens, and user interactions.

## Review Priorities

What matters most in review?

- Correctness:
- Security/privacy:
- Performance:
- Accessibility:
- Offline behavior:
- Compatibility:
- Release safety:

## Conventions

- Naming:
- Error handling:
- Logging:
- State management:
- Navigation:
- Testing:
- Formatting:

## Commands

- Build:
- Unit tests:
- UI/integration tests:
- Lint:
- Type check:
- Release build:

## Known Risk Areas

- None identified yet. Add entries as you discover them (e.g. "Auth token is stored in plain SharedPreferences").

## Active Migrations

- None in progress. Add entries when a migration is underway (e.g. "Moving from Retrofit to Ktor — not complete in feature/ branches").

## Things That Look Odd But Are Intentional

- None. Add entries for patterns that look wrong but are deliberate (e.g. "We suppress X lint rule because of Y").
