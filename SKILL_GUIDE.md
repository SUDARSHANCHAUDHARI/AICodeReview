# Skill Contributor Guide

This guide covers everything you need to write a new AICodeReview skill and get it accepted.

---

## Folder structure

Every skill lives in `skills/<skill-name>/` and must contain:

```
skills/
  <skill-name>/
    SKILL.md              # canonical definition (prompt + workflow)
    agents/
      openai.yaml         # OpenAI Codex (Responses API tool definition)
      cursor.mdc          # Cursor rule (Markdown with MDC frontmatter)
      copilot.md          # GitHub Copilot (plain Markdown instructions)
      gemini.md           # Google Gemini (plain Markdown instructions)
      aider.md            # Aider (plain Markdown conventions)
```

All five agent files are required. `./scripts/validate.sh` fails if any are missing.

---

## SKILL.md frontmatter

`SKILL.md` must start with a YAML frontmatter block:

```markdown
---
name: <skill-name>
description: <one sentence; when to use this skill and what value it provides>
---
```

- `name`: must match the folder name exactly.
- `description`: used by Claude Code to decide when to suggest this skill.
  Write it as a `Use when ...` sentence. Keep it under 200 characters.

After the frontmatter, write the full skill prompt in Markdown. Use `##` sections
for Workflow, What To Check, and Output.

---

## Writing effective skill prompts

### 1. Start with inspection, not assumptions

The first step of every workflow must be to read relevant files before reviewing:

```markdown
## Workflow

1. Inspect the repo: current path, git status, branch, changed files, relevant diffs.
2. Read PROJECT_CONTEXT.md, AGENTS.md, and any relevant config files.
3. Review the changed code in context of the surrounding system.
```

This prevents the model from reviewing a diff without understanding the surrounding code.

### 2. Be concrete about what to check

Vague guidance produces vague reviews. List specific concerns:

```markdown
## What To Check

- SQL queries: look for N+1 patterns, missing indexes, unbounded result sets.
- Error handling: every DB call must propagate errors; no silent swallows.
- Migrations: backward-compatible? Down migration present?
```

### 3. Define the output format explicitly

Use the standard severity format so findings are consistent across skills:

```markdown
## Output

Start with findings, ordered by severity.

**[P0]** `path/to/file.ext:123` - Short title
Explanation and concrete fix direction.

**[P1]** `path/to/file.ext:45` - Short title
...
```

Severity guide:

| Level | Meaning |
|-------|---------|
| P0 | Must fix before merge/release: data loss, security breach, crash, broken core workflow |
| P1 | Should fix: likely production bug, significant regression, missing critical test |
| P2 | Useful fix: maintainability, edge case, minor performance risk |
| P3 | Optional polish: mention sparingly, never block a merge on P3 alone |

### 4. Do not take destructive actions

Every skill prompt must end with or imply this constraint:

> Do not edit files, push, publish, or change repo settings unless the user explicitly
> asks for that action.

---

## Agent file formats

### openai.yaml

Follows the OpenAI Responses API tool definition schema:

```yaml
name: <skill-name>
description: <same one-liner as SKILL.md>
parameters:
  type: object
  properties: {}
  required: []
instructions: |
  <full skill prompt, same content as SKILL.md body>
```

### cursor.mdc

Cursor rules use Markdown with an MDC YAML frontmatter block:

```
---
description: <same one-liner>
globs:
  - "**/*.ext"
alwaysApply: false
---

<full skill prompt>
```

- `globs`: file patterns that trigger this rule automatically. Use `**/*` for
  skills that apply to any file, or limit to relevant extensions.
- `alwaysApply: false` is correct for most skills; set `true` only for skills
  that should run on every edit (e.g., a security scan).

### copilot.md

Plain Markdown. No special format. GitHub Copilot reads this file as context.

Write the skill prompt as-is. The install script wraps all copilot.md files inside
an AICodeReview section marker in `.github/copilot-instructions.md`:

```
# >>> AICodeReview START <<<
<content of all copilot.md files concatenated>
# >>> AICodeReview END <<<
```

Everything outside the markers is preserved on update or uninstall. Do not include
the markers in your copilot.md file — they are added automatically.

### gemini.md

Same as copilot.md. Plain Markdown, no markers. The install script injects it into
`GEMINI.md` inside the AICodeReview section.

### aider.md

Same as copilot.md. Plain Markdown, injected into `CONVENTIONS.md`.

---

## Adding a skill to install.sh and uninstall.sh

Both files contain a `skills=(...)` array. Add the new skill name (the folder name)
in alphabetical order:

```bash
skills=(
  "accessibility-audit"
  "api-design-review"
  "your-new-skill"      # <-- add here
  ...
)
```

The arrays in both files must be identical. `./scripts/validate.sh` checks that
every skill folder is referenced in both files.

---

## Running validation before you submit

```bash
./scripts/validate.sh
```

This checks:

- `install.sh` and `uninstall.sh` have no shell syntax errors.
- Every skill folder has `SKILL.md` with valid frontmatter.
- Every skill folder has all five agent files.
- Every skill folder is referenced in both `install.sh` and `uninstall.sh`.

Fix all failures before opening a PR. The PR checklist requires `validate.sh` to pass.

---

## Running tests

```bash
./tests/run-all.sh
```

Runs all test suites in `tests/test-*.sh`. All suites must pass.

---

## Naming conventions

- Use kebab-case for folder names: `api-design-review`, not `ApiDesignReview`.
- Keep names short and specific: `graphql-review` not `graphql-schema-and-resolver-review`.
- Suffix with `-review` for review skills, `-audit` for audit/compliance skills,
  `-writer` for generation skills, `-planner` for planning/suggestion skills.

---

## Common mistakes to avoid

- Leaving a `...` placeholder in any agent file — every file must be complete.
- Forgetting to add the skill to both `install.sh` AND `uninstall.sh`.
- Writing `alwaysApply: true` in cursor.mdc for a skill that is only useful on demand.
- Including AICodeReview section markers in copilot.md / gemini.md / aider.md —
  the install script adds them; duplicates will break idempotent updates.
- Using absolute paths in prompts — the skill runs in different repo roots.
