# Customising AICodeReview

Each workflow is defined canonically in `skills/<skill-name>/SKILL.md`.

Use reusable skills for cross-project behavior and `PROJECT_CONTEXT.md` for repository-specific conventions, commands, architecture, and known risks.

## Skill structure

```text
skills/<skill-name>/
├── SKILL.md
└── agents/
    └── openai.yaml
```

- `SKILL.md` is installed natively for Claude Code, Codex, GitHub Copilot, Gemini CLI, and OpenCode.
- `openai.yaml` is generated interface metadata.
- Cursor rules are generated from `SKILL.md` during installation.
- Aider receives a compact generated catalog plus canonical skill directories under `.aicodereview/skills/`.

Do not add `cursor.mdc`, `copilot.md`, `gemini.md`, or `aider.md` to a skill directory.

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

Edit only the relevant `SKILL.md`:

```markdown
## Workflow

1. Inspect repository state and relevant files.
2. Review the implementation in context.
3. Report findings with severity, evidence, file and line, impact, and fix direction.
4. Identify missing verification.
```

Review and audit workflows remain read-only unless the user explicitly requests changes.

## Add a new skill

Create:

```text
skills/my-skill/
└── SKILL.md
```

Minimum content:

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

Generate the OpenAI metadata:

```bash
python3 scripts/skill_artifacts.py sync-openai --write
```

The installer discovers the new directory automatically. Do not edit a hard-coded inventory.

Run:

```bash
python3 scripts/skill_artifacts.py validate
python3 scripts/skill_artifacts.py sync-openai --check
./scripts/validate.sh
./tests/run-all.sh
```

## Preview generated adapters

Cursor:

```bash
python3 scripts/skill_artifacts.py render-cursor \
  --skill my-skill \
  --output /tmp/my-skill.mdc
```

Aider catalog:

```bash
python3 scripts/skill_artifacts.py render-aider \
  --output /tmp/AICODEREVIEW.md
```

The catalog should remain compact. The full workflow is loaded in Aider from the installed canonical file:

```text
/read .aicodereview/skills/my-skill/SKILL.md
```

## Add an integration

Before implementing a new agent, identify its actual capability:

- Native on-demand skill directory
- Project rule
- Persistent instructions
- Convention file
- Lifecycle hook

Prefer native on-demand skills when supported.

A complete integration requires:

1. Install path and scope.
2. Update detection.
3. Inventory and health reporting.
4. Ownership markers.
5. Unmanaged-conflict backups.
6. Safe uninstall.
7. Migration from any previous adapter.
8. Full preflight before combined installation.
9. Behavioral tests.
10. Accurate documentation.

Do not claim that rules, persistent instructions, conventions, and hooks are equivalent to skills.

## Versioning changes

- Keep behavior changes focused.
- Update documentation when a skill name, path, or capability changes.
- Add an entry under `Unreleased` in `CHANGELOG.md`.
- Test generation, dry-run, new install, managed update, unmanaged conflict, migration, selective Aider loading, and uninstall behavior.
- Never put private project details in reusable skills.
