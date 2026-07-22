# AICodeReview Agent Context

AICodeReview is a portable code-review workflow pack. Every workflow has one canonical `SKILL.md`. Native agents receive that directory directly. Cursor rules, a compact Aider catalog, and OpenAI product metadata are generated from the canonical source.

## Repository structure

- `skills/<name>/SKILL.md` is the workflow used by Claude Code, Codex, GitHub Copilot, Gemini CLI, OpenCode, and selective Aider loading.
- `skills/<name>/agents/openai.yaml` is generated OpenAI interface metadata.
- `scripts/skill_artifacts.py` validates skills, synchronizes OpenAI metadata, renders Cursor rules, and renders the compact Aider catalog.
- `aicodereview-lib.sh` contains ownership, backup, migration, and inventory helpers.
- `install.sh`, `uninstall.sh`, `update.sh`, `list-installed.sh`, and `check-health.sh` manage integrations.
- `templates/PROJECT_CONTEXT.md` provides repository-specific context.

Do not add `cursor.mdc`, `copilot.md`, `gemini.md`, or `aider.md` under a skill directory. Those files are obsolete duplicated adapters and validation rejects them.

## Supported integrations

| Agent | Install target | Adapter |
|---|---|---|
| Claude Code | `~/.claude/skills/` | Native skill |
| OpenAI Codex | `~/.codex/skills/` | Native skill |
| GitHub Copilot | `<project>/.github/skills/` | Native skill |
| Gemini CLI | `<project>/.gemini/skills/` | Native skill |
| OpenCode | `<project>/.opencode/skills/` | Native skill |
| Cursor | `<project>/.cursor/rules/` | Generated `.mdc` rule |
| Aider | `<project>/AICODEREVIEW.md` and `<project>/.aicodereview/skills/` | Compact catalog plus selective skill files |

Legacy Copilot, Gemini, and Aider managed sections are migration inputs only.

## Development rules

- Treat `SKILL.md` as the only workflow source.
- Discover skills dynamically from `skills/`; never add hard-coded skill arrays.
- Regenerate OpenAI metadata with `python3 scripts/skill_artifacts.py sync-openai --write`.
- Keep generated metadata quoted and ensure the default prompt invokes `$skill-name`.
- Generate Cursor output and the Aider catalog through `scripts/skill_artifacts.py`; do not maintain prompt copies.
- Keep the Aider catalog compact. Full workflows belong under `.aicodereview/skills/` and are loaded individually with `/read`.
- Preserve user-owned files and configuration.
- Replace or remove only ownership-marked content.
- `--force` must back up unmanaged conflicts.
- Validate every migration marker before mutation.
- Preflight all adapters before an all-agent operation writes the first file.
- Never create a duplicate top-level `read` key in `.aider.conf.yml`.
- Keep review and audit workflows read-only unless the user explicitly requests changes.
- Never commit secrets, signing material, private customer data, or `.env` values.

## Validation

```bash
python3 scripts/skill_artifacts.py validate
python3 scripts/skill_artifacts.py sync-openai --check
./scripts/validate.sh
./tests/run-all.sh
```

Installer changes require behavioral coverage for generation, new installs, managed updates, unmanaged conflicts, migration, partial-install prevention, selective Aider loading, dry runs, and ownership-aware uninstall.

## Current phases

- Phase 0: safe installation, migration, native multi-agent support, and CI.
- Phase 1: standardized metadata, generated Cursor rules, and selective Aider workflow loading.
- Phase 2: cross-platform TypeScript CLI and Windows support.
- Phase 3: optional hooks and behavioral evaluation repositories.
