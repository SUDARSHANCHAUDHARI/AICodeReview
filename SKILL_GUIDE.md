# Skill Contributor Guide

This guide explains how to add or change an AICodeReview workflow.

## Canonical structure

Each workflow lives under:

```text
skills/<skill-name>/
├── SKILL.md
└── agents/
    └── openai.yaml
```

`SKILL.md` is the only workflow source. Claude Code, Codex, GitHub Copilot, Gemini CLI, and OpenCode receive that native directory. Aider receives the same canonical skill files under `.aicodereview/skills/` for selective `/read` loading.

`agents/openai.yaml` is generated product metadata. Cursor rules and the compact Aider catalog are generated at installation time.

Never add these obsolete duplicate adapters:

```text
cursor.mdc
copilot.md
gemini.md
aider.md
```

## SKILL.md frontmatter

Every skill starts with:

```markdown
---
name: <skill-name>
description: <what the skill does and when an agent should activate it>
---
```

Requirements:

- `name` matches the directory exactly.
- Use lowercase letters, numbers, and single hyphens.
- `description` is specific enough for correct on-demand selection.
- Keep the description within 1,024 characters.
- Do not include secrets or private repository data.

Optional resources may live beside `SKILL.md`:

```text
scripts/
references/
assets/
examples/
```

Reference supporting files explicitly from the workflow.

## Writing effective workflows

### Inspect before judging

Start by reading repository state and relevant context:

```markdown
## Workflow

1. Inspect the current path, branch, git status, changed files, and relevant diffs.
2. Read PROJECT_CONTEXT.md, AGENTS.md, README, and nearby implementation and tests.
3. Review the change in the context of the surrounding system.
```

### Focus on evidence

Each finding should include:

1. Severity.
2. File and line.
3. Observed evidence.
4. Failure scenario or impact.
5. Concrete fix direction.
6. Relevant test gap.

Do not report a defect when the necessary implementation was not inspected.

### Severity model

| Level | Meaning |
|---|---|
| P0 | Must fix before merge or release: security breach, data loss, crash, or broken core workflow |
| P1 | Should fix: likely production bug, significant regression, or missing critical coverage |
| P2 | Useful fix: edge case, maintainability risk, or minor performance problem |
| P3 | Optional polish; use sparingly |

### Keep reviews read-only

Review and audit skills must not edit files, push changes, publish artifacts, or alter repository settings unless the user explicitly asks.

Generation and fixer skills must still avoid ambiguous or destructive changes.

## OpenAI metadata

Generate metadata after adding or renaming a skill:

```bash
python3 scripts/skill_artifacts.py sync-openai --write
```

The generated shape is:

```yaml
interface:
  display_name: "Code Review"
  short_description: "Run the Code Review workflow"
  default_prompt: "Use $code-review to apply this workflow to the current repository."
```

Rules:

- Metadata strings are quoted.
- `short_description` is 25–64 characters.
- `default_prompt` contains `$skill-name`.
- Do not hand-edit generated metadata unless you also update the renderer.

Verify committed metadata with:

```bash
python3 scripts/skill_artifacts.py sync-openai --check
```

## Cursor generation

Cursor rules are rendered from `SKILL.md`:

```bash
python3 scripts/skill_artifacts.py render-cursor \
  --skill code-review \
  --output /tmp/code-review.mdc
```

Generated rules use:

```yaml
---
description: "<SKILL.md description>"
globs: []
alwaysApply: false
---
```

Do not maintain a separate Cursor workflow copy.

## Aider generation and loading

The renderer creates a compact workflow catalog:

```bash
python3 scripts/skill_artifacts.py render-aider \
  --output /tmp/AICODEREVIEW.md
```

The catalog must remain small. It lists workflow names and descriptions and explains how to load one full skill:

```text
/read .aicodereview/skills/code-review/SKILL.md
```

The installer:

1. Writes the compact `AICODEREVIEW.md` catalog.
2. Copies canonical skill directories to `.aicodereview/skills/` with ownership markers.
3. Adds the catalog to `.aider.conf.yml` only when doing so does not create a duplicate `read` key.

Do not combine all full workflow bodies into the catalog. That would load unnecessary context into every Aider session.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md`.
2. Run `python3 scripts/skill_artifacts.py sync-openai --write`.
3. Run validation.
4. Run the full behavioral test suite.
5. Update README and CHANGELOG when the public inventory changes.

The maintenance scripts discover skill directories dynamically. Do not add hard-coded arrays.

## Integration safety

Installer changes must preserve these guarantees:

- Unmanaged paths are never silently overwritten or deleted.
- `--force` backs up an unmanaged conflict before replacement.
- Uninstall removes only ownership-marked content.
- Legacy markers are validated before migration.
- Combined multi-agent commands preflight every adapter before writing.
- Generated artifact validation happens before installation.
- Aider configuration never gains a duplicate top-level `read` key.
- Unmanaged Aider skill directories remain untouched during uninstall.

## Validation

```bash
python3 scripts/skill_artifacts.py validate
python3 scripts/skill_artifacts.py sync-openai --check
./scripts/validate.sh
```

Validation checks:

- Shell and Python syntax.
- Skill directory naming and frontmatter.
- Standardized OpenAI metadata.
- Absence of obsolete duplicated adapters.
- Native integration paths.
- Dynamic skill discovery.
- Generated Cursor rules and compact Aider catalog behavior.

## Tests

```bash
./tests/run-all.sh
```

Behavioral tests should cover:

- Artifact generation.
- New install.
- Managed update.
- Unmanaged conflict and backup preservation.
- Legacy migration and corrupt markers.
- Multi-agent partial-install prevention.
- Selective Aider workflow installation and cleanup.
- Dry-run behavior.
- Uninstall ownership.
- User configuration preservation.

## Common mistakes

- Adding a second workflow source outside `SKILL.md`.
- Hand-maintaining Cursor, Copilot, Gemini, or Aider prompt copies.
- Embedding all Aider workflows into the auto-loaded catalog.
- Forgetting to regenerate OpenAI metadata.
- Adding a hard-coded skill list.
- Overwriting an unmanaged destination.
- Removing a file without checking its ownership marker.
- Writing before every target in an all-agent operation has passed preflight.
- Duplicating a top-level `read` key in `.aider.conf.yml`.
- Reporting style preferences instead of evidence-based defects.
- Using absolute paths in reusable skills.
