---
name: android-review
description: Use when reviewing Android, Kotlin, Kotlin Multiplatform, Jetpack Compose, Room, Hilt, Gradle, Play Store release, or mobile app changes.
---

# Android Review

## Workflow

1. Inspect repo state, changed files, Gradle files, manifests, and relevant source/tests.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, README, and nearby architecture patterns when present.
3. Review changed code for Android-specific correctness, lifecycle safety, UI behavior, release risk, and tests.
4. Do not edit, push, publish, or change repo settings unless explicitly asked.

## Checklist

- Compose: state hoisting, stable state, recomposition safety, previews where useful.
- ViewModel: exposes `StateFlow<UiState>`, handles events clearly, avoids leaking Android `Context`.
- Coroutines: structured concurrency, correct dispatchers, cancellation-safe work.
- Persistence: Room off main thread, migrations considered, DataStore for new preferences.
- Architecture: data/domain/presentation boundaries match existing repo patterns.
- DI: Hilt modules are scoped correctly and do not create duplicate bindings.
- Navigation: arguments are typed/validated and back behavior is predictable.
- Accessibility: content descriptions, touch targets, readable text, dark mode where relevant.
- Security: no secrets, keystores, signing material, sensitive logs, or unsafe exported components.
- Release: AAB-oriented, versioning sane, privacy-impacting changes called out.
- Tests: changed use cases/ViewModels/mappers have focused tests where repo patterns exist.

## Output

Lead with findings:

```markdown
## Android Review Findings

**[P1]** `path/to/file.kt:42` - Short title
Why this matters and how to fix it.

## Verification

- Commands run or not run.

## Summary

Verdict and remaining risk.
```
