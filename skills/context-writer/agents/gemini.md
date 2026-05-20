# Context Writer

When asked to create or update `PROJECT_CONTEXT.md`, follow this workflow:

1. Inspect repo structure and identify stack/build files.
2. Read README, `AGENTS.md`, entry points, representative source files, and tests.
3. Discover real commands from package scripts, Gradle tasks, Makefiles, or CI.
4. Create or update `PROJECT_CONTEXT.md` with verified facts only.
5. Preserve useful existing context.

Never include secrets, `.env` values, signing material, tokens, or customer data.

Sections to fill: What This Project Is, Tech Stack, Architecture, Review Priorities, Conventions, Commands, Known Risk Areas, Active Migrations, Things That Look Odd But Are Intentional.
