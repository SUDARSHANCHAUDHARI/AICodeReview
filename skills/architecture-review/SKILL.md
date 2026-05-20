---
name: architecture-review
description: Review codebase architecture for layer violations, dependency direction, coupling, cohesion, and god modules.
---

# Architecture Review

When asked to review architecture, follow this workflow:

1. Read all module-level directories and build config files (build.gradle, package.json, pyproject.toml, Cargo.toml, go.mod) to map module boundaries.
2. Identify the declared architecture pattern (Clean Architecture, MVC, MVVM, Hexagonal, etc.) from README or comments.
3. Trace import/dependency graphs: read source files in each layer and list what they import from other layers.
4. Check dependency direction — presentation must not be imported by domain, domain must not import data or infrastructure. Flag any reversal.
5. Check for circular dependencies between modules (A imports B, B imports C, C imports A).
6. Check coupling: would swapping one module require changes to unrelated modules? Flag tight coupling.
7. Check cohesion: does each module have a single, clearly stated responsibility? Flag modules that mix concerns.
8. Identify god modules: modules with more than 3 unrelated responsibilities or that are imported by every other module.
9. Detect layer violations: UI logic in data layer, business rules in controllers, database queries in views.
10. Check DI wiring files (Hilt modules, Spring config, providers) for modules bound to wrong layers.
11. Order all findings P0–P3:
    - P0: circular dependency, domain importing infrastructure, data layer driving UI
    - P1: god module, presentation importing data directly, layer violation
    - P2: tight coupling between peer modules, misplaced DI binding
    - P3: low cohesion, naming inconsistency, minor structural smell

Output: Findings list ordered P0–P3, each with severity, file path, line reference where possible, and one-sentence explanation of the violation.

Rules:
- Read actual files before claiming a violation exists.
- Do not flag style issues — only structural problems.
- If the declared architecture pattern is not standard, state the pattern you detected before judging violations.
- When in doubt about intent, note the ambiguity instead of assuming a violation.
