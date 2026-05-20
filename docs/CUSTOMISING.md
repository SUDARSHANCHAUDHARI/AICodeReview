# Customising AICodeReview

Each workflow is defined in `skills/<skill-name>/SKILL.md`. Agent-specific configs live alongside it in `skills/<skill-name>/agents/`.

Edit the skill text when you want different review behavior. Put reusable cross-project rules in skills and project-specific rules in `PROJECT_CONTEXT.md`.

## Skill Structure

```
skills/<skill-name>/
  SKILL.md              ← shared prompt (Claude Code + Codex native format)
  agents/
    openai.yaml         ← Codex display metadata
    cursor.mdc          ← Cursor rule
    copilot.md          ← GitHub Copilot instructions snippet
    gemini.md           ← Gemini CLI instructions
    aider.md            ← Aider conventions snippet
```

## Add Project Rules

For a project-specific convention, prefer `PROJECT_CONTEXT.md` in the target repo:

```markdown
## Conventions

- All new Android UI uses Jetpack Compose.
- ViewModels expose `StateFlow<UiState>`.
- Repositories are accessed through domain interfaces.
```

All skills read `PROJECT_CONTEXT.md` when present, so the same installed skills adapt to multiple repos automatically.

## Add Framework Rules

Add focused checklist items to the relevant skill's `SKILL.md`.

For Android/Kotlin:

```markdown
- Compose state should be hoisted where practical and stable across recompositions.
- ViewModels should not hold Android `Context` unless using `Application` intentionally.
- Coroutine work should use structured concurrency and avoid leaking scopes.
- Room access should not run on the main thread.
```

For web apps:

```markdown
- Server endpoints validate input at boundaries.
- Client components do not import server-only modules.
- Loading, empty, and error states exist for user-facing data fetches.
- Secrets are never exposed through public environment variables.
```

## Skill List

| Skill | Purpose |
|---|---|
| `code-review` | General code review |
| `security-audit` | Security and privacy audit |
| `codebase-explainer` | Repo explanation and onboarding |
| `review-fixer` | Safe fix application |
| `android-review` | Android/Kotlin/KMP-specific review |
| `release-review` | Release readiness check |
| `pr-summary` | PR description writing |
| `context-writer` | Project context creation |

## Add A New Skill

1. Create the skill folder:

```
skills/my-skill/
  SKILL.md
  agents/
    openai.yaml
    cursor.mdc
    copilot.md
    gemini.md
    aider.md
```

2. Minimum `SKILL.md` shape:

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

3. Add the skill name to the `skills` array in `install.sh` and `uninstall.sh`.

4. Run validation:

```bash
./scripts/validate.sh
```

## Add A New Agent

1. Add the agent config file to every skill under `skills/*/agents/<agent-name>.<ext>`.
2. Update `install.sh` to handle the new agent.
3. Update `uninstall.sh` to handle removal.
4. Update `validate.sh` to check the new agent file exists in each skill.
5. Document the new agent in README and docs.

## Versioning Your Changes

- One skill behavior change per commit.
- Update docs when a skill name or install path changes.
- Test install with `./install.sh --dry-run` before sharing.
- Avoid putting private project details directly into reusable skills.
