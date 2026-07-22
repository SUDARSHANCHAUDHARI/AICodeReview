# AICodeReview Agent Context

AICodeReview is a portable code-review workflow pack. Every workflow has one canonical `SKILL.md`. Native agents receive that directory directly. Cursor rules, a compact Aider catalog, and OpenAI metadata are generated from the canonical source.

## Repository structure

- `skills/<name>/SKILL.md` is the only workflow source.
- `skills/<name>/agents/openai.yaml` is generated interface metadata.
- `src/runtime.ts` implements install, uninstall, list, health, update, validation, and generation.
- `src/hooks.ts` installs optional Copilot and Gemini lifecycle hooks.
- `hooks/runner.js` records deterministic Git state and must emit valid JSON only.
- `src/eval.ts` validates fixtures and scores result files.
- `evals/manifest.json` defines seeded defects and false-positive controls.
- `bin/aicodereview.js` dispatches runtime, hooks, and evaluation commands.

Do not add `cursor.mdc`, `copilot.md`, `gemini.md`, or `aider.md` under a skill directory. Validation rejects those duplicated adapters.

## Development rules

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
- Install hooks only for agents with documented hook formats.
- Hooks must be optional, non-destructive, and explicit about what they do.
- Hook stdout must contain only the protocol JSON expected by the host.
- Hook reports are deterministic repository evidence, not AI review results.
- Evaluation fixtures must contain fake or synthetic data only.
- Include at least one false-positive control in every evaluation category.
- Do not advertise behavioral support without reproducible evaluation results.
- Keep review and audit workflows read-only unless the user explicitly requests changes.
- Never commit secrets, signing material, private customer data, or `.env` values.

## Validation

```bash
npm install
npm test
npm run validate
npm run pack:check
```

GitHub Actions must cover Ubuntu, macOS, and Windows. Repository-only shell compatibility is checked separately on Ubuntu and macOS.

## Completed phases

- Phase 0: safe ownership, migration, native multi-agent support, and CI configuration.
- Phase 1: canonical workflows, metadata generation, Cursor rules, and selective Aider loading.
- Phase 2: complete cross-platform Node CLI, maintenance commands, and package validation.
- Phase 3: optional documented hooks and reproducible behavioral evaluation fixtures.
