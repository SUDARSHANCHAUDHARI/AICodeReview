# Customising AICodeReview

Each workflow is defined canonically in `skills/<skill-name>/SKILL.md`.

Use reusable skills for cross-project behavior and `PROJECT_CONTEXT.md` for repository-specific conventions, commands, architecture, and known risks.

## Skill structure

```text
skills/<skill-name>/
  SKILL.md
  agents/
    openai.yaml
    cursor.mdc
    copilot.md
    gemini.md
    aider.md
```

Current roles:

- `SKILL.md` is installed natively for Claude Code, Codex, GitHub Copilot, Gemini CLI, and OpenCode.
- `openai.yaml` contains Codex-facing metadata pending Phase 1 standardization.
- `cursor.mdc` is the Cursor rule adapter.
- `aider.md` is compact source content for the generated `AICODEREVIEW.md` file.
- `copilot.md` and `gemini.md` remain temporarily for legacy migration and will be removed or generated in Phase 1.

Do not add new Copilot or Gemini behavior only to their legacy Markdown adapters. Native agents must receive the behavior through `SKILL.md`.

## Add project rules

Put project-specific conventions in `PROJECT_CONTEXT.md`:

```markdown
## Conventions

- All new Android UI uses Jetpack Compose.
- ViewModels expose StateFlow<UiState>.
- Repositories are accessed through domain interfaces.
```

Skills read this file when present.

## Change a workflow

Edit the relevant `SKILL.md` and keep the workflow evidence-based:

```markdown
## Workflow

1. Inspect repository state and relevant files.
2. Review the implementation in context.
3. Report findings with severity, evidence, file and line, impact, and fix direction.
4. Identify missing verification.
```

Review and audit skills must remain read-only unless the user explicitly requests changes.

## Add a new skill

Create:

```text
skills/my-skill/
  SKILL.md
  agents/
    openai.yaml
    cursor.mdc
    copilot.md
    gemini.md
    aider.md
```

Minimum `SKILL.md`:

```markdown
---
name: my-skill
description: Use when the agent should perform this specific workflow.
---

# My Skill

## Workflow

1. Inspect the relevant files.
2. Perform the task using repository evidence.
3. Verify the result.
4. Report what changed and what remains.
```

The installer discovers the directory automatically. Do not add a hard-coded skill name to install, uninstall, inventory, or health scripts.

Run:

```bash
./scripts/validate.sh
./tests/run-all.sh
```

## Add an integration

Before implementing a new agent, determine its actual capability:

- Native on-demand skill directory
- Project rule
- Persistent instructions
- Convention file
- Lifecycle hook

Prefer a native on-demand skill when supported.

A complete integration requires:

1. Install path and scope.
2. Update detection.
3. Inventory and health reporting.
4. Ownership markers.
5. Unmanaged-conflict backups.
6. Safe uninstall.
7. Migration from any previous adapter.
8. Behavioral tests.
9. Accurate documentation.

Do not claim that rules, persistent instructions, conventions, and hooks are equivalent to skills.

## Versioning changes

- Keep behavior changes focused.
- Update documentation when a skill name, path, or capability changes.
- Add an entry under `Unreleased` in `CHANGELOG.md`.
- Test dry-run, new install, managed update, unmanaged conflict, migration, and uninstall behavior.
- Never put private project details in reusable skills.
