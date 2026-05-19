---
name: codex-context-writer
description: Use when creating or updating PROJECT_CONTEXT.md by studying an existing repository's stack, architecture, conventions, commands, risk areas, and active migrations.
---

# Codex Context Writer

## Workflow

1. Inspect the repo structure and identify stack/build files.
2. Read README/docs, `AGENTS.md`, entry points, representative source files, and tests.
3. Discover real commands from package scripts, Gradle tasks, Makefiles, CI, or docs.
4. Create or update `PROJECT_CONTEXT.md` with verified facts only.
5. Preserve useful existing context and avoid private data.

## Context Sections

Use these sections when relevant:

- What This Project Is
- Tech Stack
- Architecture
- Review Priorities
- Conventions
- Commands
- Known Risk Areas
- Active Migrations
- Things That Look Odd But Are Intentional

## Rules

- Do not guess stack details.
- Do not include secrets, `.env` values, signing material, tokens, or customer data.
- Mark uncertainty clearly.
- Prefer concise, actionable context over long explanations.

## Output

Summarize what was added or updated and what the user should verify.
