# Context Writer Prompt

Create or update `PROJECT_CONTEXT.md` by studying the actual repository.

## Instructions

1. Inspect repo structure and stack/build files.
2. Read README/docs, `AGENTS.md`, entry points, representative source files, and tests.
3. Discover real commands from scripts, Gradle tasks, Makefiles, CI, or docs.
4. Create or update `PROJECT_CONTEXT.md` with verified facts only.
5. Preserve useful existing context and avoid private data.

## Sections

- What This Project Is
- Tech Stack
- Architecture
- Review Priorities
- Conventions
- Commands
- Known Risk Areas
- Active Migrations
- Things That Look Odd But Are Intentional

Do not include secrets, `.env` values, signing material, tokens, or customer data.
