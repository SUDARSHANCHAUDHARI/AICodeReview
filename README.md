# Codex Review Kit

Codex-native code review workflows you can drop into any repository.

This project is inspired by prompt-pack projects like `opencode-review`, but it is built for Codex skills and for practical solo-developer workflows: Android, Kotlin Multiplatform, web apps, CLIs, scripts, and small product repos.

## What You Get

- `codex-code-review`: production-focused review for bugs, regressions, security, performance, and missing tests.
- `codex-security-audit`: threat-model driven audit for injection, auth, secrets, data exposure, config, and dependency risk.
- `codex-codebase-explainer`: architecture and data-flow explanation for onboarding or returning to an old repo.
- `codex-review-fixer`: conservative fixer for concrete review findings.
- `PROJECT_CONTEXT.md` template: a per-project memory file that keeps AI reviews grounded in your actual conventions.

## Install

```bash
./install.sh
```

This copies the skills into:

```text
~/.codex/skills/
```

To install from a cloned checkout:

```bash
git clone https://github.com/SUDARSHANCHAUDHARI/codex-review-kit.git
cd codex-review-kit
./install.sh
```

## Use

After installing, ask Codex things like:

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
Use codex-review-fixer to fix the review findings that are safe and obvious.
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

## License

MIT
