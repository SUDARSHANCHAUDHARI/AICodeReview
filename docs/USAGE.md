# Usage

## Install

```bash
git clone https://github.com/SUDARSHANCHAUDHARI/AICodeReview.git
cd AICodeReview
```

**Claude Code + Codex (default):**

```bash
./install.sh
```

**Single agent:**

```bash
./install.sh --agent claude
./install.sh --agent codex
```

**Project-local agents:**

```bash
./install.sh --agent cursor  --project /path/to/your/project
./install.sh --agent copilot --project /path/to/your/project
./install.sh --agent gemini  --project /path/to/your/project
./install.sh --agent aider   --project /path/to/your/project
```

Preview without writing files:

```bash
./install.sh --dry-run
./install.sh --agent cursor --project /path/to/project --dry-run
```

Overwrite existing installed skills:

```bash
./install.sh --force
```

## First Time In A Repo

1. Copy `templates/PROJECT_CONTEXT.md` into the target repo.
2. Fill in the real stack, conventions, commands, and risk areas.
3. Ask your AI agent to review or explain the repo using the installed skills.

Example:

```text
Use codebase-explainer to study this repo and help me fill PROJECT_CONTEXT.md.
```

## Before Committing

```text
Use code-review to review my current changes.
```

For Android/KMP work:

```text
Use code-review and focus on Compose state, ViewModel state flow, coroutine usage, Gradle config, and missing tests.
```

Or use the Android-specific skill:

```text
Use android-review to review my current Android changes.
```

## Before Releasing

```text
Use security-audit and focus on release-blocking risks.
```

For Android releases:

```text
Use security-audit and check for secrets, signing material, exported components, WebView risk, cleartext traffic, and sensitive logging.
```

For release readiness:

```text
Use release-review to check whether this build is ready to ship.
```

## Fixing Findings

```text
Use review-fixer to fix only concrete and low-risk findings from the last review.
```

## Writing PR Notes

```text
Use pr-summary to write a PR description for my current changes.
```

## Writing Project Context

```text
Use context-writer to create PROJECT_CONTEXT.md for this repo.
```

## Good Review Inputs

The best reviews include:

- A clean git diff.
- A current `PROJECT_CONTEXT.md`.
- Known test/build commands.
- Clear release target, when relevant.

## What Not To Put In Context

- Secrets or `.env` values.
- Signing keys or keystore passwords.
- Private customer data.
- Private API tokens.

## Suggested Workflow

1. Keep `PROJECT_CONTEXT.md` current in each important repo.
2. Run `code-review` before commits or PRs.
3. Run `security-audit` before release branches or production deploys.
4. Use `review-fixer` only after reading the findings.
5. Run your normal project tests/builds after fixes.
6. Use `pr-summary` when you are ready to open a PR.

## Agent-Specific Notes

### Claude Code / Codex

Skills are installed globally and triggered by name:

```text
Use code-review to review my current changes.
```

### Cursor

Rules are installed per-project into `.cursor/rules/`. Cursor picks them up automatically based on context. You can also invoke them directly in your prompt.

### GitHub Copilot

Instructions are written to `.github/copilot-instructions.md`. Copilot reads this file in supported editors automatically.

### Gemini CLI

Instructions are written to `GEMINI.md` in your project root. Gemini CLI reads this file when present.

### Aider

Conventions are written to `CONVENTIONS.md` in your project root. Aider reads this file automatically.
