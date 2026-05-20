## Code Smell Detector Convention

When asked to detect code smells:

1. Read all source files in scope.
2. Flag god classes: over 500 lines or more than 10 public methods.
3. Flag long methods: over 50 lines.
4. Flag feature envy: a method uses another class more than its own.
5. Flag dead code: unused functions, unread variables, unreachable branches.
6. Flag duplicate blocks: 6+ identical lines appearing in multiple files/locations.
7. Flag magic numbers: inline numeric literals without a named constant (exclude obvious 0/1/-1).
8. Flag boolean flag parameters: a boolean argument that forks a function into different behaviours.
9. Flag deep nesting: conditional or loop depth greater than 3 levels.
10. Output P0–P3 findings with file:line and a one-line fix suggestion for each.
