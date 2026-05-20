---
name: codebase-explainer
description: Use when explaining a repository's architecture, modules, data flow, conventions, testing approach, risk areas, or onboarding map. Useful for filling or refreshing PROJECT_CONTEXT.md.
---

# Codebase Explainer

## Workflow

1. Inspect the repo shape and identify stack files such as `package.json`, `build.gradle.kts`, `settings.gradle.kts`, `go.mod`, `pyproject.toml`, `Cargo.toml`, or equivalents.
2. Read README/docs, `PROJECT_CONTEXT.md`, `AGENTS.md`, entry points, representative files from each major layer, and tests.
3. Build a mental model from actual files. Do not guess.
4. Explain how the system works and where to change common things.
5. If asked, create or update `PROJECT_CONTEXT.md` with verified facts only.

## Output

```markdown
## What This Project Does

...

## Architecture

...

## Key Modules

`path/` - responsibility and boundaries.

## Representative Flow

Step-by-step path through real files/functions.

## Conventions

...

## Testing And Verification

...

## Risk Areas

...

## Where To Change Things

- Add a screen:
- Add a use case:
- Add persistence:
- Add tests:
```

Keep the explanation practical. Name actual files and commands.
