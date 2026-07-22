# AICodeReview Agent Context

AICodeReview is a portable code-review workflow pack. Every workflow has one canonical `SKILL.md`. Native agents receive that directory directly. Cursor rules, a compact Aider catalog, and OpenAI product metadata are generated from the canonical source.

## Repository structure

- `skills/<name>/SKILL.md` is the workflow used by native agents and selective Aider loading.
- `skills/<name>/agents/openai.yaml` is generated OpenAI interface metadata.
- `src/cli.ts` is the cross-platform TypeScript implementation for install, uninstall, validation, and metadata generation.
- `bin/aicodereview.js` loads the compiled CLI from `dist/cli.js`.
- `scripts/skill_artifacts.py` and the shell maintenance commands remain temporarily for Phase 2 compatibility.
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
- Keep TypeScript and temporary shell behavior aligned until Phase 2B removes the runtime shell dependency.
- Generate metadata through `node bin/aicodereview.js generate --write` after building.
- Keep generated metadata quoted and ensure the default prompt invokes `$skill-name`.
- Generate Cursor output and the Aider catalog from canonical skills; do not maintain prompt copies.
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
npm install
npm run build
npm test
npm run test:shell
```

Node CLI changes require behavior coverage on Windows, macOS, and Linux for new installs, managed updates, unmanaged conflicts, migration, partial-install prevention, selective Aider loading, dry runs, and ownership-aware uninstall.

## Current phases

- Phase 0: safe installation, migration, native multi-agent support, and CI.
- Phase 1: standardized metadata, generated Cursor rules, and selective Aider workflow loading.
- Phase 2A: cross-platform install, uninstall, validate, and generate commands.
- Phase 2B: cross-platform list, health, update, packaging, and shell/Python retirement.
- Phase 3: optional hooks and behavioral evaluation repositories.
