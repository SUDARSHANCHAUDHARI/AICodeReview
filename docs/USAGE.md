# Usage

## Install

```bash
git clone https://github.com/SUDARSHANCHAUDHARI/CodexReviewKit.git
cd CodexReviewKit
./install.sh
```

This copies the skill folders into `~/.codex/skills`.

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

## Before Releasing

```text
Use codex-security-audit and focus on release-blocking risks.
```

For Android releases:

```text
Use codex-security-audit and check for secrets, signing material, exported components, WebView risk, cleartext traffic, and sensitive logging.
```

## Fixing Findings

```text
Use codex-review-fixer to fix only concrete and low-risk findings from the last review.
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
