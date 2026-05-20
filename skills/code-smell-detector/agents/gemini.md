# Code Smell Detector

When asked to detect code smells, follow this workflow:

1. List all source files in scope; read each one.
2. Flag god classes: files over 500 lines or classes with more than 10 public methods.
3. Flag long methods: any function or method over 50 lines.
4. Flag feature envy: methods that reference another class's fields/methods more than their own.
5. Flag dead code: unused functions, unread variables, unreachable conditional branches.
6. Flag duplicate blocks: identical or near-identical segments of 6+ lines in multiple locations.
7. Flag magic numbers: inline numeric literals with no named constant or comment (exclude obvious 0/1/-1).
8. Flag boolean flag parameters: booleans that split a function into fundamentally different paths.
9. Flag deep nesting: if/else, try/catch, or loop depth greater than 3 levels.
10. Output all findings ordered P0–P3 with file:line and a one-line fix suggestion each.

Check: god class, long method, feature envy, dead code, duplicates, magic numbers, boolean flags, deep nesting.

Order findings P0–P3 with file:line references.
