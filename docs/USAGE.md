# Usage

## Supported Formats

| Tool | Files |
| --- | --- |
| Codex | `skills/*/SKILL.md` |
| OpenCode | `.opencode/commands/*.md` |
| Claude Code | `.claude/commands/*.md` |
| Cursor | `.cursor/rules/ai-review-kit.mdc` |
| Windsurf | `.windsurf/rules/ai-review-kit.md` |
| Generic | `prompts/*.md` |

## Install For Codex

```bash
git clone https://github.com/SUDARSHANCHAUDHARI/AICodeReview.git
cd AICodeReview
./install.sh
```

This copies the skill folders into `~/.codex/skills`.

Preview install without writing files:

```bash
./install.sh --dry-run
```

Overwrite existing installed skills:

```bash
./install.sh --force
```

## OpenCode

Copy `.opencode/commands/` into a repo or keep it in this repo while working here.

Available commands:

```text
/review
/review-security
/explain
/fix-review
/review-android
/review-release
/pr-summary
/write-context
```

## Claude Code

Copy `.claude/commands/` into a repo.

Available commands:

```text
/review
/review-security
/explain
/fix-review
/review-android
/review-release
/pr-summary
/write-context
```

## Cursor

Copy `.cursor/rules/ai-review-kit.mdc` into a repo, then ask Cursor to use the rule for reviews, audits, PR summaries, or context writing.

## Windsurf

Copy `.windsurf/rules/ai-review-kit.md` into a repo, then ask Windsurf to use the rule for reviews, audits, PR summaries, or context writing.

## Generic Prompts

Copy prompts from `prompts/` into any AI coding tool:

```text
code-review.md
security-audit.md
codebase-explainer.md
review-fixer.md
android-review.md
release-review.md
pr-summary.md
context-writer.md
```

## First Time In A Repo

1. Copy `templates/PROJECT_CONTEXT.md` into the target repo.
2. Fill in the real stack, conventions, commands, and risk areas.
3. Ask Codex to review or explain the repo using the installed skills.

Example:

```text
Use codex-codebase-explainer to study this repo and help me fill PROJECT_CONTEXT.md.
```

## Before Committing

```text
Use codex-code-review to review my current changes.
```

For Android/KMP work:

```text
Use codex-code-review and focus on Compose state, ViewModel state flow, coroutine usage, Gradle config, and missing tests.
```

Or use the Android-specific skill:

```text
Use codex-android-review to review my current Android changes.
```

## Before Releasing

```text
Use codex-security-audit and focus on release-blocking risks.
```

For Android releases:

```text
Use codex-security-audit and check for secrets, signing material, exported components, WebView risk, cleartext traffic, and sensitive logging.
```

For release readiness:

```text
Use codex-release-review to check whether this build is ready to ship.
```

## Fixing Findings

```text
Use codex-review-fixer to fix only concrete and low-risk findings from the last review.
```

## Writing PR Notes

```text
Use codex-pr-summary to write a PR description for my current changes.
```

## Writing Project Context

```text
Use codex-context-writer to create PROJECT_CONTEXT.md for this repo.
```

## Good Review Inputs

The best reviews include:

- A clean git diff.
- A current `PROJECT_CONTEXT.md`.
- Known test/build commands.
- Clear release target, when relevant.

## Bad Review Inputs

Avoid putting these into context or prompts:

- Secrets or `.env` values.
- Signing keys or keystore passwords.
- Private customer data.
- Private API tokens.

## Suggested Workflow

1. Keep `PROJECT_CONTEXT.md` current in each important repo.
2. Run `codex-code-review` before commits or PRs.
3. Run `codex-security-audit` before release branches or production deploys.
4. Use `codex-review-fixer` only after reading the findings.
5. Run your normal project tests/builds after fixes.
6. Use `codex-pr-summary` when you are ready to open a PR.
