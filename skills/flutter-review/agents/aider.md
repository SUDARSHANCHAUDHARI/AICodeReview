## Flutter Review Convention

When asked to review Flutter/Dart code:

1. Check `const` constructors used where possible.
2. Check `setState` on smallest widget; no `setState` after `dispose`.
3. Check `.builder` for dynamic `ListView`/`GridView`.
4. Check no heavy computation in `build()`.
5. Check `dispose()` called for AnimationController, TextEditingController, FocusNode, streams.
6. Check heavy work offloaded to `Isolate`/`compute`.
7. Check `FutureBuilder`/`StreamBuilder` handle waiting, error, and data states.
8. Check platform channels namespaced and data types serialisable.
9. Check no hardcoded secrets; `flutter_secure_storage` for sensitive data.
10. Check release: version updated, `flutter analyze` clean, obfuscation enabled.
11. Order findings P0–P3 with lib/path/file.dart:line references.
