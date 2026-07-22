# Contributing

Thanks for improving AICodeReview.

## Local safety

- Do not commit secrets, `.env` values, signing keys, API tokens, or private customer data.
- Preserve user-owned files and configuration when changing installers.
- Test installer changes with dry runs and temporary project directories.
- Preflight every destination before a multi-agent command writes its first file.
- Do not publish, rename the repository, or change visibility unless explicitly requested.

## Editing a skill

The canonical workflow is:

```text
skills/<skill-name>/SKILL.md
```

Each file needs YAML frontmatter:

```markdown
---
name: skill-name
description: Use when ...
---
```

Descriptions should state the concrete task and activation conditions clearly enough for on-demand selection.

Do not create separate Copilot, Gemini, OpenCode, Cursor, or Aider workflow copies. Native agents and selective Aider loading use `SKILL.md`; Cursor rules and the Aider catalog are generated from it.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md`.
2. Create the `agents/` directory if needed.
3. Generate the OpenAI metadata:

```bash
python3 scripts/skill_artifacts.py sync-openai --write
```

4. Run validation and tests:

```bash
./scripts/validate.sh
./tests/run-all.sh
```

5. Update README and CHANGELOG when the public inventory changes.

Skills are discovered dynamically. Do not add an installer array.

## Generated artifacts

Committed OpenAI metadata must match the generator:

```bash
python3 scripts/skill_artifacts.py sync-openai --check
```

Cursor rules and `AICODEREVIEW.md` are rendered at installation time. Aider skill directories are copied from canonical `SKILL.md` files to `.aicodereview/skills/` so users can load one workflow with `/read`.

Do not commit these obsolete per-skill files:

```text
cursor.mdc
copilot.md
gemini.md
aider.md
```

Keep the generated Aider catalog compact. It should list available workflows and explain selective loading, not embed all workflow bodies.

## Adding an integration

1. Confirm whether the agent supports native skills, project rules, conventions, persistent instructions, or hooks.
2. Prefer native on-demand skills where available.
3. Add install, update, inventory, health, and uninstall behavior.
4. Add ownership and unmanaged-conflict handling.
5. Add migration logic for replaced adapters.
6. Add an all-agent preflight when the integration participates in combined installation.
7. Add behavioral tests proving user-owned content is preserved.
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
python3 scripts/skill_artifacts.py validate
python3 scripts/skill_artifacts.py sync-openai --check
./install.sh --dry-run
./scripts/validate.sh
./tests/run-all.sh
```

Installer and migration changes should also be tested against unmanaged conflicts, corrupt legacy markers, selective Aider skill paths, and existing user configuration.
