---
name: code-smell-detector
description: Detect code smells including god classes, long methods, dead code, duplicates, magic numbers, and deeply nested conditionals.
---

# Code Smell Detector

When asked to detect code smells, follow this workflow:

1. List all source files in the target scope (directory or diff).
2. For each file, count lines and public methods. Flag files over 500 lines or classes with more than 10 public methods as god classes.
3. Scan every method/function for length. Flag any method over 50 lines as a long method candidate.
4. Detect feature envy: methods that call methods or access fields of another class more than their own class. Note the envying method and the target class.
5. Detect dead code: functions never called outside their own file, variables assigned but never read, conditional branches that can never be reached (e.g., after unconditional return, always-false condition).
6. Find duplicate code blocks: identical or near-identical blocks of 6 or more lines appearing in more than one place. Note all file:line locations.
7. Find magic numbers: numeric literals that appear inline with no named constant or explanatory comment. Exclude 0, 1, -1 where semantically obvious.
8. Find boolean flag parameters: function parameters of type boolean where the flag controls fundamentally different behaviour inside the function.
9. Detect deeply nested conditionals: if/else, try/catch, or loop nesting depth greater than 3 levels.
10. Order all findings P0–P3:
    - P0: god class that owns business-critical logic and is actively modified
    - P1: long method in hot path, feature envy causing cross-module coupling, unreachable branch hiding a bug
    - P2: duplicate block, boolean flag parameter, god class in utility code
    - P3: magic number, minor nesting depth, small dead code block
11. Output each finding with: severity, smell type, file:line, and a one-sentence fix suggestion.

Output: Findings list P0–P3 with file references and fix suggestions.

Rules:
- Read actual file contents before claiming a smell — do not guess from file names.
- Magic number rule applies to source code only, not test fixtures or seed data.
- Dead code must be confirmed unused before flagging — check all callers in scope.
- Do not flag intentional overrides or interface implementations as dead code.
