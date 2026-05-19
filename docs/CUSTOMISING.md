# Customising Codex Review Kit

Each workflow has multiple formats:

- Codex skills in `skills/<skill-name>/SKILL.md`.
- Generic prompts in `prompts/*.md`.
- OpenCode commands in `.opencode/commands/*.md`.
- Claude Code commands in `.claude/commands/*.md`.
- Cursor rules in `.cursor/rules/*.mdc`.
- Windsurf rules in `.windsurf/rules/*.md`.

Edit the generic prompt first when you want behavior to apply across tools, then keep tool-specific files aligned.

Prefer project-specific rules in `PROJECT_CONTEXT.md` and reusable cross-project rules in skills.

## Add Project Rules

For a project-specific convention, prefer `PROJECT_CONTEXT.md` in the target repo:

```markdown
## Conventions

- All new Android UI uses Jetpack Compose.
- ViewModels expose `StateFlow<UiState>`.
- Repositories are accessed through domain interfaces.
```

The skills instruct Codex to read project context when present, so the same installed skills can adapt to multiple repos.

## Add Framework Rules

Add focused checklist items to the relevant skill.

For Android/Kotlin:

```markdown
- Compose state should be hoisted where practical and stable across recompositions.
- ViewModels should not hold Android `Context` unless using `Application` intentionally.
- Coroutine work should use structured concurrency and avoid leaking scopes.
- Room access should not run on the main thread.
- Release changes should not expose signing config, secrets, or private store metadata.
```

For web apps:

```markdown
- Server endpoints validate input at boundaries.
- Client components do not import server-only modules.
- Loading, empty, and error states exist for user-facing data fetches.
- Secrets are never exposed through public environment variables.
```

## Skill List

- `codex-code-review`: general code review.
- `codex-security-audit`: security and privacy audit.
- `codex-codebase-explainer`: repo explanation.
- `codex-review-fixer`: safe fix application.
- `codex-android-review`: Android/Kotlin/KMP-specific review.
- `codex-release-review`: release readiness.
- `codex-pr-summary`: PR description writing.
- `codex-context-writer`: project context creation.

## Add A New Skill

Create a new Codex skill folder:

```text
skills/my-skill/
  SKILL.md
```

Use this minimum shape:

```markdown
---
name: my-skill
description: Use when ...
---

# My Skill

## Workflow

1. Inspect the relevant files.
2. Do the task.
3. Verify the result.
4. Report what changed and what remains.
```

Then add the folder name to `install.sh`.

For multi-tool support, also add:

- `prompts/<workflow>.md`
- `.opencode/commands/<workflow>.md`
- `.claude/commands/<workflow>.md`
- Cursor/Windsurf rule references if the workflow should be discoverable there.

## Versioning Your Changes

If you maintain a personal fork, keep changes small and reviewable:

- One skill behavior change per commit.
- Update docs when a prompt name or install path changes.
- Test install with `./install.sh` before sharing.
- Avoid putting private project details directly into reusable skills.
