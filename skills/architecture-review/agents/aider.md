## Architecture Review Convention

When asked to review architecture:

1. Read all module directories and build config files to map module boundaries.
2. Identify the declared architecture pattern from README or inline comments.
3. Trace imports in each layer; verify direction is presentation → domain → data only.
4. Flag reversals: domain importing data, data importing presentation, UI importing persistence.
5. Detect circular dependencies between modules.
6. Flag god modules with more than 3 unrelated responsibilities.
7. Flag tight coupling: swapping one module forces changes in unrelated modules.
8. Flag low cohesion: a single module mixes concerns that belong elsewhere.
9. Inspect DI wiring for bindings registered in the wrong layer.
10. Output findings as P0–P3 with file:line references and one-line explanation per finding.
