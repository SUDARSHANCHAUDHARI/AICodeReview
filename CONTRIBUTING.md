# Contributing

Thanks for improving AICodeReview.

## Local safety

- Do not commit secrets, `.env` values, signing keys, keystores, API tokens, or private customer data.
- Keep project-specific private context in your own repositories, not in reusable skills.
- Preserve user-owned files and configuration when changing installers.
- Test installer changes with dry runs and temporary project directories.
- Preflight every destination before a multi-agent command writes its first file.
- Do not publish, push unrelated branches, rename the repository, or change visibility unless explicitly requested.

## Editing skills

The canonical workflow lives in:

```text
skills/<skill-name>/SKILL.md
```

Each `SKILL.md` needs YAML frontmatter:

```markdown
---
name: skill-name
description: Use when ...
---
```

Descriptions should explain the concrete task and trigger conditions clearly enough for on-demand skill selection.

The canonical directory is installed natively for Claude Code, Codex, GitHub Copilot, Gemini CLI, and OpenCode. Do not maintain separate full workflow copies for those agents.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md`.
2. Add the required files under `skills/<skill-name>/agents/`.
3. Add a compact Cursor rule and Aider convention where appropriate.
4. Run validation and the full behavioral test suite.
5. Update README and CHANGELOG when the public inventory changes.

Skill directories are discovered dynamically. Do not add the skill name to an installer array.

## Adding an agent integration

1. Confirm whether the agent supports native `SKILL.md` directories, rules, persistent instructions, conventions, or hooks.
2. Prefer native on-demand skills when available.
3. Add install, update, inventory, health, and uninstall behavior.
4. Add ownership and unmanaged-conflict handling.
5. Add migration logic when replacing an existing adapter.
6. Add behavioral tests covering preservation of user-owned content.
7. Add an all-agent preflight when the integration participates in a combined install.
8. Update README, AGENTS.md, SKILL_GUIDE.md, issue templates, and CHANGELOG.

Do not describe skills, rules, conventions, and hooks as equivalent capabilities.

## Prompt quality

- Inspect repository state and relevant files before making claims.
- Focus on correctness, security, performance, testing, and operational risk.
- Include evidence, file and line references, impact, and a concrete fix direction.
- Avoid taste-based findings.
- Keep review and audit workflows read-only unless the user explicitly requests changes.
- Put repository-specific conventions in `PROJECT_CONTEXT.md`.

## Before sharing

```bash
./install.sh --dry-run
./scripts/validate.sh
./tests/run-all.sh
```

Installer or migration changes should also be tested against temporary projects containing unmanaged conflicts, corrupt legacy markers, and existing configuration.
