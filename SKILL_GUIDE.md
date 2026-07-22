# Skill Contributor Guide

This guide explains how to add or change an AICodeReview workflow.

## Canonical structure

Each workflow lives under `skills/<skill-name>/`:

```text
skills/
  <skill-name>/
    SKILL.md
    agents/
      openai.yaml
      cursor.mdc
      copilot.md
      gemini.md
      aider.md
```

`SKILL.md` is the canonical workflow. Claude Code, Codex, GitHub Copilot, Gemini CLI, and OpenCode receive that native skill directory.

The files under `agents/` currently serve these roles:

| File | Current role |
|---|---|
| `openai.yaml` | Codex product-facing skill metadata |
| `cursor.mdc` | Cursor project rule |
| `copilot.md` | Legacy adapter retained temporarily for migration and Phase 1 generation work |
| `gemini.md` | Legacy adapter retained temporarily for migration and Phase 1 generation work |
| `aider.md` | Compact Aider conventions used to generate `AICODEREVIEW.md` |

Phase 1 will remove unnecessary manual duplication and generate non-native adapters from `SKILL.md`.

## SKILL.md frontmatter

Every `SKILL.md` must start with:

```markdown
---
name: <skill-name>
description: <what the skill does and when an agent should activate it>
---
```

Requirements:

- `name` must match the directory name.
- Use lowercase letters, numbers, and single hyphens.
- `description` must be specific enough for an agent to select the skill correctly.
- Keep the description within 1,024 characters.
- Do not put project secrets or private repository data in reusable skills.

Optional resources may be added beside `SKILL.md`:

```text
scripts/
references/
assets/
examples/
```

Reference them explicitly in the workflow.

## Writing effective workflows

### Inspect before judging

Start by reading the relevant repository state:

```markdown
## Workflow

1. Inspect the current path, branch, git status, changed files, and relevant diffs.
2. Read PROJECT_CONTEXT.md, AGENTS.md, README, and nearby implementation and tests.
3. Review the change in the context of the surrounding system.
```

### Focus on evidence

A finding should identify:

1. Severity.
2. File and line.
3. Observed evidence.
4. Failure scenario or impact.
5. Concrete fix direction.
6. Relevant test gap.

Do not report a defect when the necessary implementation was not inspected.

### Use the shared severity model

| Level | Meaning |
|---|---|
| P0 | Must fix before merge or release: security breach, data loss, crash, or broken core workflow |
| P1 | Should fix: likely production bug, significant regression, or missing critical coverage |
| P2 | Useful fix: edge case, maintainability risk, or minor performance problem |
| P3 | Optional polish; use sparingly |

### Keep review skills read-only

Review and audit skills must not edit files, push changes, publish artifacts, or alter repository settings unless the user explicitly asks.

Generation and fixer skills must still avoid ambiguous or destructive changes.

## Adapter guidance

### Native Agent Skills

Do not create separate Copilot, Gemini, or OpenCode prompt copies for new behavior. Their current installers copy the canonical skill directory to:

```text
.github/skills/<skill-name>/
.gemini/skills/<skill-name>/
.opencode/skills/<skill-name>/
```

Claude Code and Codex use their global skill locations.

### Cursor

`cursor.mdc` uses MDC frontmatter:

```markdown
---
description: <specific trigger description>
globs: []
alwaysApply: false
---

<compact workflow>
```

Use `alwaysApply: false` for on-demand review workflows. Add globs only when the rule is genuinely file-type-specific.

### Aider

`aider.md` should be a compact convention, not a full duplicate of a large skill. All Aider adapters are combined into the generated `AICODEREVIEW.md` file.

### OpenAI metadata

The repository currently contains legacy top-level fields in `openai.yaml`. Phase 1 will migrate these files to the official nested `interface:` format. Until that migration is complete, keep new files consistent with the existing repository and treat validation warnings as known debt.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md`.
2. Add the required files under `skills/<skill-name>/agents/`.
3. Run validation.
4. Run all behavioral tests.
5. Update README and CHANGELOG when the public skill inventory changes.

The maintenance scripts discover skill directories dynamically. Do not add the skill name to hard-coded shell arrays.

## Validation

```bash
./scripts/validate.sh
```

Validation checks:

- Shell syntax.
- Skill directory naming.
- `SKILL.md` frontmatter.
- Required adapter files.
- Native Copilot, Gemini, and OpenCode installation paths.
- Dynamic skill discovery.
- Known metadata migration warnings.

## Tests

```bash
./tests/run-all.sh
```

Tests must cover behavior, not only file existence. For installer changes, include scenarios for:

- New install.
- Managed update.
- Unmanaged conflict.
- Backup preservation.
- Legacy migration.
- Corrupt migration markers.
- Uninstall ownership.
- Dry-run behavior.
- User configuration preservation.

## Common mistakes

- Treating persistent instructions as equivalent to on-demand skills.
- Adding a new hard-coded skill list.
- Overwriting an unmanaged destination.
- Removing a file without checking its ownership marker.
- Duplicating a top-level `read` key in `.aider.conf.yml`.
- Leaving Copilot or Gemini legacy sections after a successful native migration.
- Writing vague prompts that produce style commentary instead of evidence-based findings.
- Using absolute paths in reusable skills.
