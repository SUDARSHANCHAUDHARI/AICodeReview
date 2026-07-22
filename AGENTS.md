# AICodeReview Agent Context

AICodeReview is a portable code-review workflow pack. Every workflow has one canonical `SKILL.md`. Native agents receive that directory directly. Cursor rules, a compact Aider catalog, and OpenAI product metadata are generated from the canonical source.

## Repository structure

- `skills/<name>/SKILL.md` is the workflow used by native agents and selective Aider loading.
- `skills/<name>/agents/openai.yaml` is generated OpenAI interface metadata.
- `src/runtime.ts` is the complete cross-platform Node CLI.
- `bin/aicodereview.js` loads `dist/runtime.js`.
- `tests/node-cli.test.js` and `tests/node-maintenance.test.js` cover install, uninstall, list, health, update, migration, and backup behavior.
- Shell and Python utilities remain only for backward-compatibility testing and are not published in the npm package.

Do not add `cursor.mdc`, `copilot.md`, `gemini.md`, or `aider.md` under a skill directory. Validation rejects those duplicated adapters.

## Supported integrations

| Agent | Install target | Adapter |
|---|---|---|
| Claude Code | `~/.claude/skills/` | Native skill |
| OpenAI Codex | `~/.codex/skills/` | Native skill |
| GitHub Copilot | `<project>/.github/skills/` | Native skill |
| Gemini CLI | `<project>/.gemini/skills/` | Native skill |
| OpenCode | `<project>/.opencode/skills/` | Native skill |
| Cursor | `<project>/.cursor/rules/` | Generated rule |
| Aider | `<project>/AICODEREVIEW.md` and `<project>/.aicodereview/skills/` | Compact catalog plus selective skills |

## Development rules

- Treat `SKILL.md` as the only workflow source.
- Discover skills dynamically; never add hard-coded inventories.
- Keep all published commands Node-only and cross-platform.
- Generate metadata through `aicodereview generate --write`.
- Preserve user-owned files and configuration.
- Replace or remove only ownership-marked content.
- Back up unmanaged conflicts before forced replacement.
- Keep file and marker replacement transactional with rollback.
- Validate migration markers before mutation.
- Preflight every target before an all-agent operation writes.
- Keep the Aider catalog compact and load full workflows selectively.
- Keep review and audit workflows read-only unless the user explicitly requests changes.
- Never commit secrets, signing material, private customer data, or `.env` values.

## Validation

```bash
npm install
npm test
npm run validate
npm run pack:check
```

GitHub Actions must cover Ubuntu, macOS, and Windows. Legacy shell compatibility is tested separately on Ubuntu and macOS.

## Current phases

- Phase 0: safe installation, migration, native multi-agent support, and CI.
- Phase 1: canonical workflows, metadata generation, Cursor rules, and selective Aider loading.
- Phase 2: complete cross-platform Node CLI, maintenance commands, and package validation.
- Phase 3: optional lifecycle hooks and behavioral evaluation fixtures.
