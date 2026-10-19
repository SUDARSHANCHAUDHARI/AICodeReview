# Usage

## Install

```bash
git clone https://github.com/SUDARSHANCHAUDHARI/AICodeReview.git
cd AICodeReview
```

Install Claude Code and Codex globally:

```bash
./install.sh
```

Install a single global agent:

```bash
./install.sh --agent claude
./install.sh --agent codex
```

Install project-scoped integrations:

```bash
./install.sh --agent cursor   --project /path/to/project
./install.sh --agent copilot  --project /path/to/project
./install.sh --agent gemini   --project /path/to/project
./install.sh --agent opencode --project /path/to/project
./install.sh --agent aider    --project /path/to/project
```

Install everything:

```bash
./install.sh --agent all --project /path/to/project
```

The all-agent command validates every destination and legacy migration marker before writing any files.

Preview changes:

```bash
./install.sh --agent all --project /path/to/project --dry-run
```

Update managed installs or migrate legacy adapters:

```bash
./install.sh --agent copilot --project /path/to/project --force
./update.sh --project /path/to/project
```

`--force` backs up an unmanaged conflicting path before replacement.

## First use in a repository

1. Copy `templates/PROJECT_CONTEXT.md` into the target repository.
2. Fill in the actual stack, architecture, commands, conventions, and risk areas.
3. Ask the agent to use the relevant review workflow.

```text
Use codebase-explainer to study this repository and help me complete PROJECT_CONTEXT.md.
```

## Common workflows

Before committing:

```text
Use code-review to review my current changes.
```

For Android or Kotlin work:

```text
Use android-review to review my current Android changes.
```

Before releasing:

```text
Use security-audit and focus on release-blocking risks.
Use release-review to check whether this build is ready to ship.
```

Fixing findings:

```text
Use review-fixer to fix only concrete and low-risk findings from the last review.
```

Writing pull request notes:

```text
Use pr-summary to write a pull request description for my current changes.
```

Writing project context:

```text
Use context-writer to create PROJECT_CONTEXT.md for this repository.
```

## Good review inputs

- A focused Git diff.
- A current `PROJECT_CONTEXT.md`.
- Known verification commands.
- The intended release or deployment target.
- Relevant logs or failure details.

Do not put secrets, signing material, customer data, or private tokens into context files.

## Agent-specific behavior

### Claude Code

Native skills are installed under `~/.claude/skills/`.

### OpenAI Codex

Native skills are installed under `~/.codex/skills/`.

### GitHub Copilot

Native project skills are installed under `.github/skills/`. Older managed content in `.github/copilot-instructions.md` is removed during migration while user-owned instructions are preserved.

### Gemini CLI

Native workspace skills are installed under `.gemini/skills/`. Run `/skills reload` after installation. Older managed content in `GEMINI.md` is removed during migration while user-owned context is preserved.

### OpenCode

Native project skills are installed under `.opencode/skills/`.

### Cursor

Rules are installed per project under `.cursor/rules/` and can be selected or applied by Cursor.

### Aider

The installer generates `AICODEREVIEW.md`.

When `.aider.conf.yml` does not already contain a user-managed `read` setting, AICodeReview adds:

```yaml
read:
  - AICODEREVIEW.md
```

When a `read` setting already exists, add `AICODEREVIEW.md` to that existing list manually. The installer will not add a duplicate top-level key.

## Check status

```bash
./list-installed.sh --project /path/to/project
./check-health.sh --project /path/to/project
```

Inventory status values:

- `installed`: managed current-format integration exists.
- `legacy`: old managed instructions exist but native migration is pending.
- `unmanaged`: a conflicting user-owned path or corrupt marker state exists.
- `missing`: no installation was found.

## Uninstall

```bash
./uninstall.sh --agent copilot --project /path/to/project
./uninstall.sh --agent all --project /path/to/project
```

Only AICodeReview-managed paths and sections are removed.
