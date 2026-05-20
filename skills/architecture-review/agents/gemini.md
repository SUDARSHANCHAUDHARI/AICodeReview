# Architecture Review

When asked to review architecture, follow this workflow:

1. Read all module-level directories and build config files to map module boundaries.
2. Identify the declared architecture pattern (Clean Architecture, MVC, MVVM, Hexagonal) from README or inline comments.
3. Trace import/dependency graphs by reading source files in each layer and listing cross-layer imports.
4. Verify dependency direction: presentation → domain → data only. Flag any reversal.
5. Detect circular dependencies between modules.
6. Check coupling: flag modules where swapping one requires changes in unrelated modules.
7. Check cohesion: flag modules that mix more than one responsibility.
8. Identify god modules: more than 3 unrelated responsibilities or imported by every other module.
9. Inspect DI wiring files for bindings registered in the wrong layer.
10. Detect layer violations: UI logic in data layer, business rules in controllers, DB queries in views.

Check: dependency direction, circular deps, god modules, DI layer placement, tight coupling, low cohesion, layer violations.

Order findings P0–P3 with file:line references.
