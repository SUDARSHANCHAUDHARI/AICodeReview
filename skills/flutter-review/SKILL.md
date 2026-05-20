---
name: flutter-review
description: Use when reviewing Flutter or Dart code: widget tree, state management, platform channels, isolates, pub dependencies, or app store release config.
---

# Flutter Review

## Workflow

1. Inspect changed Dart files, `pubspec.yaml`, and relevant widget/state/test files.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, and README for state management approach and architecture.
3. Review for Flutter/Dart-specific correctness, performance, and release risk.
4. Do not edit, push, or change settings unless explicitly asked.

## Checklist

### Widget Tree & Performance
- `const` constructors used wherever possible to avoid unnecessary rebuilds.
- `setState` called only for the smallest widget that needs to rebuild — not high up the tree unnecessarily.
- `ListView` / `GridView` uses `.builder` for long or dynamic lists, not a pre-built `children` list.
- `InheritedWidget` or state management solution (Provider, Riverpod, Bloc, GetX) used consistently with the project's chosen approach.
- No heavy computation (parsing, sorting, decoding) inside `build()` methods.
- `RepaintBoundary` considered for widgets that animate independently.

### State Management
- State not held in widgets that rebuild frequently when a lower scope would suffice.
- Streams/`StreamBuilder` have correct lifecycle: subscribed in `initState`, cancelled in `dispose`.
- `dispose()` called correctly on `AnimationController`, `TextEditingController`, `FocusNode`, etc.
- No `setState` called after `dispose` (causes framework exception).

### Async / Isolates
- Heavy work (image processing, JSON parsing of large payloads, crypto) offloaded to `Isolate` or `compute`.
- `async`/`await` used over raw `Future.then` chains.
- Errors in async code caught and surfaced to the user, not silently swallowed.
- `FutureBuilder` and `StreamBuilder` handle `ConnectionState.waiting`, error, and data states explicitly.

### Platform Channels
- Method channel names are namespaced: `com.example.app/channel_name`.
- Platform channel calls have error handling on both Dart and native side.
- Data types passed over platform channels are serialisable (no custom objects directly).

### Pub Dependencies
- `pubspec.yaml` version constraints are not overly loose (`^` prefix used, not `>=0.0.0`).
- Dev dependencies not in `dependencies` (only in `dev_dependencies`).
- No abandoned or unmaintained packages for critical functionality.

### Security
- No hardcoded API keys or secrets in Dart source — use `--dart-define` or a secrets file excluded from VCS.
- Sensitive data not stored in `SharedPreferences` unencrypted — use `flutter_secure_storage`.
- No debug flags or dev endpoints active in release builds.

### Release
- `pubspec.yaml` version and build number updated.
- `flutter build appbundle` (Android) and `flutter build ipa` (iOS) succeed cleanly.
- `flutter analyze` and `dart fix` have no errors.
- Obfuscation enabled for release: `--obfuscate --split-debug-info`.

## Output

```markdown
## Flutter Review Findings

**[P1]** `lib/screens/home_screen.dart:88` - Heavy JSON parsing in build()
Parsing runs on every rebuild. Move to initState or a FutureBuilder outside the build path.

## Summary

Verdict and remaining risk.
```
