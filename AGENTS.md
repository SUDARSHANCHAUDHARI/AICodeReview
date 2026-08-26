# AICodeReview Agent Context

AICodeReview is a portable code-review workflow pack. Each workflow has a canonical `SKILL.md` that is installed natively for agents supporting the Agent Skills model. Cursor and Aider use generated adapters.

## Repository structure

- `skills/` contains one canonical skill directory per workflow.
- `skills/<name>/SKILL.md` is the native workflow used by Claude Code, Codex, GitHub Copilot, Gemini CLI, and OpenCode.
- `skills/<name>/agents/openai.yaml` contains Codex-facing metadata pending Phase 1 standardization.
- `skills/<name>/agents/cursor.mdc` is the Cursor rule adapter.
- `skills/<name>/agents/aider.md` contributes to the generated Aider conventions file.
- `aicodereview-lib.sh` contains shared ownership, backup, migration, and inventory helpers.
- `install.sh`, `uninstall.sh`, `update.sh`, `list-installed.sh`, and `check-health.sh` manage integrations.
- `templates/PROJECT_CONTEXT.md` provides repository-specific review context.
- `examples/` contains example project context files.

## Supported integrations

| Agent | Install target | Adapter |
|---|---|---|
| Claude Code | `~/.claude/skills/` | Native skill |
| OpenAI Codex | `~/.codex/skills/` | Native skill |
| GitHub Copilot | `<project>/.github/skills/` | Native skill |
| Gemini CLI | `<project>/.gemini/skills/` | Native skill |
| OpenCode | `<project>/.opencode/skills/` | Native skill |
| Cursor | `<project>/.cursor/rules/` | Generated `.mdc` rule |
| Aider | `<project>/AICODEREVIEW.md` | Generated conventions file |

Copilot and Gemini legacy managed sections are migration inputs only. Do not add new review workflows to `.github/copilot-instructions.md` or `GEMINI.md`.

## Development rules

- Treat `SKILL.md` as the canonical workflow.
- Discover skills dynamically from directories under `skills/`; do not add hard-coded skill arrays.
- Preserve user-owned files and configuration.
- Replace or remove only paths carrying an AICodeReview ownership marker.
- `--force` must back up unmanaged conflicts before replacement.
- Validate legacy section markers before migration and stop before mutation when markers are corrupt.
- Preflight all adapters before an all-agent operation writes the first file.
- Do not create a duplicate top-level `read` key in `.aider.conf.yml`.
- Keep review and audit skills read-only unless the user explicitly requests changes.
- Never commit credentials, signing material, private customer data, or `.env` values.

## Validation

```bash
./scripts/validate.sh
./tests/run-all.sh
```

Installer changes require behavioral coverage for new installs, managed updates, unmanaged conflicts, migration, partial-install prevention, dry runs, and uninstall ownership.

## Installation examples

```bash
./install.sh
./install.sh --agent copilot --project /path/to/project
./install.sh --agent gemini --project /path/to/project
./install.sh --agent opencode --project /path/to/project
./install.sh --agent all --project /path/to/project
```

## Current phases

- Phase 0: safe inventory, installation, migration, native multi-agent support, and CI.
- Phase 1: metadata standardization and generated adapter consistency.
- Phase 2: cross-platform TypeScript CLI and Windows support.
- Phase 3: optional hooks and behavioral evaluation repositories.
