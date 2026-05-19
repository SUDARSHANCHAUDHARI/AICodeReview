# CodexReviewKit

Codex-native code review skills you can drop into any repository.

This project is inspired by prompt-pack projects, but it is built around Codex skills and practical solo-developer workflows: Android, Kotlin Multiplatform, web apps, CLIs, scripts, and small product repos.

The goal is simple: give Codex enough structure to review real code changes consistently, without turning every review into a generic checklist.

## What You Get

- `codex-code-review`: production-focused review for bugs, regressions, security, performance, and missing tests.
- `codex-security-audit`: threat-model driven audit for injection, auth, secrets, data exposure, config, and dependency risk.
- `codex-codebase-explainer`: architecture and data-flow explanation for onboarding or returning to an old repo.
- `codex-review-fixer`: conservative fixer for concrete review findings.
- `PROJECT_CONTEXT.md` template: a per-project memory file that keeps AI reviews grounded in your actual conventions.

## Install

Clone the repo:

```bash
git clone https://github.com/SUDARSHANCHAUDHARI/CodexReviewKit.git
cd CodexReviewKit
```

Install the skills:

```bash
./install.sh
```

This copies the skills into:

```text
~/.codex/skills/
```

Restart Codex if the new skills do not appear immediately.

## Use

After installing, ask Codex to use one of the skills:

```text
Use codex-code-review to review my current changes.
```

```text
Use codex-security-audit on this PR.
```

```text
Use codex-codebase-explainer to explain this repository.
```

```text
Use codex-review-fixer to fix only the review findings that are safe and obvious.
```

## What Is A Codex Skill?

A Codex skill is a small folder with a `SKILL.md` file. It tells Codex when to use a workflow and how to perform it.

This repo ships skills as plain markdown so you can inspect, edit, fork, and tune them for your own projects.

## Example Prompts

```text
Use codex-code-review to review my current changes.
```

```text
Use codex-code-review and focus on Android lifecycle, Compose state, and missing tests.
```

```text
Use codex-security-audit before I publish this release build.
```

```text
Use codex-codebase-explainer to help me fill PROJECT_CONTEXT.md for this repo.
```

## Per-Project Context

Copy the template into a repo you want reviewed:

```bash
cp templates/PROJECT_CONTEXT.md /path/to/project/PROJECT_CONTEXT.md
```

Fill it with the project stack, architecture, conventions, testing commands, and known migrations. Commit it if it is safe to share with collaborators.

Do not put secrets, private keys, signing material, `.env` values, or private customer data in context files.

## Design Philosophy

- Review real risks, not taste.
- Read the actual files before making claims.
- Prefer small, working fixes over broad refactors.
- Keep findings line-referenced and severity-ranked.
- Use project context so reviews match the repo, not a generic checklist.

## Safety Notes

- Review and audit skills are read-only unless you explicitly ask Codex to make changes.
- The fixer skill is intentionally conservative and should skip ambiguous findings.
- Keep secrets, signing files, `.env` values, private keys, and customer data out of context files.

## License

MIT
