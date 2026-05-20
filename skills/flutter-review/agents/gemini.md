# Flutter Review

When asked to review Flutter/Dart code, follow this workflow:

1. Inspect changed Dart files, pubspec.yaml, and relevant widget/state/test files.
2. Read `PROJECT_CONTEXT.md` for state management approach and architecture.
3. Review for Flutter/Dart-specific correctness, performance, and release risk.
4. Do not edit unless explicitly asked.

Check: `const` constructors used, `setState` on smallest widget, `.builder` for dynamic lists, no heavy computation in `build()`, `dispose()` called for controllers/streams, no `setState` after `dispose`, heavy work in `Isolate`/`compute`, `FutureBuilder`/`StreamBuilder` handle all states, platform channels namespaced and typed. Security: no hardcoded secrets, `flutter_secure_storage` for sensitive data, no debug endpoints in release. Release: version/build number updated, `flutter analyze` clean, obfuscation enabled.

Order findings P0–P3 with lib/path/file.dart:line references.
