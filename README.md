# AICodeReview

Portable code-review workflows for multiple AI coding agents.

AICodeReview keeps every workflow in one canonical `SKILL.md`. Native agents receive that directory directly. Cursor rules, a compact Aider catalog, and OpenAI product metadata are generated from the same source.

## Skills

| Skill | What it does |
|---|---|
| `code-review` | Review changes for bugs, regressions, security, performance, and missing tests |
| `security-audit` | Threat-model-driven audit for injection, auth, secrets, data exposure, config, and dependencies |
| `codebase-explainer` | Explain architecture and data flow for onboarding or returning to a repository |
| `review-fixer` | Apply concrete, low-risk fixes from review findings |
| `android-review` | Android, Kotlin, KMP, and Compose-focused review |
| `ios-review` | iOS, macOS, Swift, SwiftUI, and Xcode-focused review |
| `web-review` | React, Next.js, TypeScript, and Node-focused review |
| `release-review` | Check release blockers, privacy, build configuration, and rollout risk |
| `pr-summary` | Write concise pull request descriptions from local changes |
| `context-writer` | Create or refresh `PROJECT_CONTEXT.md` from repository inspection |
| `changelog-writer` | Generate changelog entries from Git commits |
| `dependency-audit` | Check for outdated, vulnerable, or risky dependencies |
| `agent-config-review` | Review AI-agent configuration files for secrets, placeholders, and inconsistencies |
| `backend-review` | Review REST or GraphQL APIs, database access, auth, errors, and service layers |
| `performance-review` | Review latency, memory, N+1 queries, caching, and rendering bottlenecks |
| `accessibility-audit` | Audit semantics, keyboard navigation, ARIA, contrast, and mobile accessibility |
| `database-review` | Review schema design, indexes, migrations, query efficiency, and data integrity |
| `test-writer` | Write unit, integration, and snapshot tests matching the existing test style |
| `kmp-review` | Review Kotlin Multiplatform expect/actual use and shared/platform boundaries |
| `docker-review` | Review Dockerfiles and Compose configuration for layers, secrets, images, and health checks |
| `ci-review` | Review CI/CD pipelines, secrets, caching, test gates, and failure modes |
| `api-design-review` | Review API naming, versioning, auth, errors, idempotency, and pagination |
| `flutter-review` | Review Flutter and Dart lifecycle, rendering, state, platform channels, and release setup |
| `refactor-planner` | Plan safe incremental refactors with blast radius, rollback, and feature flags |
| `architecture-review` | Review dependency direction, circular dependencies, coupling, cohesion, and layer violations |
| `code-smell-detector` | Find god classes, long methods, feature envy, dead code, duplication, and magic values |
| `error-handling-review` | Find silent catches, missing UI error states, unsafe retries, and untyped errors |
| `graphql-review` | Review schemas, resolver N+1 problems, field-level auth, limits, and breaking changes |
| `react-native-review` | Review JS thread use, bridge calls, lists, leaks, updates, and deep-link security |
| `tech-debt-audit` | Find and prioritize TODOs, deprecated APIs, untested critical paths, and dead flags |
| `onboarding-writer` | Generate `ONBOARDING.md` from actual repository inspection |

The CLI discovers skill directories dynamically. Adding a skill does not require editing a hard-coded list.

## Agent support

| Agent | Adapter | Install target | Behavior |
|---|---|---|---|
| Claude Code | Native Agent Skill | `~/.claude/skills/` | Loaded on demand from `SKILL.md` |
| OpenAI Codex | Native Agent Skill | `~/.codex/skills/` | Loaded on demand from `SKILL.md` |
| GitHub Copilot | Native Agent Skill | `<project>/.github/skills/` | Discovered and activated when relevant |
| Gemini CLI | Native Agent Skill | `<project>/.gemini/skills/` | Discovered and activated through `activate_skill` |
| OpenCode | Native Agent Skill | `<project>/.opencode/skills/` | Loaded on demand through the native skill tool |
| Cursor | Generated project rule | `<project>/.cursor/rules/` | Generated from `SKILL.md` during installation |
| Aider | Catalog plus selective skill files | `<project>/AICODEREVIEW.md` and `<project>/.aicodereview/skills/` | Catalog is auto-loaded; the requested workflow is loaded with `/read` |

Native skills are not copied into persistent Copilot or Gemini instruction files. Aider does not preload all 31 full workflows into every session.

## Canonical structure

```text
skills/<skill-name>/
├── SKILL.md
└── agents/
    └── openai.yaml
```

`SKILL.md` is the only workflow source.

Generated OpenAI metadata uses:

```yaml
interface:
  display_name: "Code Review"
  short_description: "Run the Code Review workflow"
  default_prompt: "Use $code-review to apply this workflow to the current repository."
```

## Requirements

The cross-platform CLI requires Node.js 18 or later.

Bash and Python remain temporarily required only for the legacy `list-installed.sh`, `check-health.sh`, and `update.sh` maintenance commands. Phase 2B will move those commands to Node.js.

## Build from the repository

```bash
git clone https://github.com/SUDARSHANCHAUDHARI/AICodeReview.git
cd AICodeReview
npm install
npm run build
```

## Cross-platform CLI

Install Claude Code and Codex:

```bash
node bin/aicodereview.js install
```

Install one project integration:

```bash
node bin/aicodereview.js install --agent cursor   --project /path/to/project
node bin/aicodereview.js install --agent copilot  --project /path/to/project
node bin/aicodereview.js install --agent gemini   --project /path/to/project
node bin/aicodereview.js install --agent opencode --project /path/to/project
node bin/aicodereview.js install --agent aider    --project /path/to/project
```

Install everything:

```bash
node bin/aicodereview.js install --agent all --project /path/to/project
```

Preview without writing:

```bash
node bin/aicodereview.js install --agent all --project /path/to/project --dry-run
```

Update managed paths and back up unmanaged conflicts:

```bash
node bin/aicodereview.js install --agent all --project /path/to/project --force
```

The old flag-only form remains supported:

```bash
node bin/aicodereview.js --agent claude
```

When installed as an npm command, replace `node bin/aicodereview.js` with `aicodereview` or `npx aicodereview`.

## Installation safety

The Node CLI preserves the Phase 0 and Phase 1 safety rules:

- Every managed skill directory and generated file receives an ownership marker.
- Unmanaged conflicts stop installation unless `--force` is used.
- `--force` moves unmanaged content to a timestamped backup before replacement.
- Corrupt legacy markers stop migration before replacement paths are written.
- `--agent all` preflights every global and project destination before the first write.
- Uninstall removes only ownership-marked content.

## Generate and validate

Validate all canonical skills and committed metadata:

```bash
node bin/aicodereview.js validate
```

Check generated OpenAI metadata:

```bash
node bin/aicodereview.js generate --check
```

Regenerate metadata:

```bash
node bin/aicodereview.js generate --write
```

Equivalent npm scripts:

```bash
npm run validate
npm run generate
```

Do not create `cursor.mdc`, `copilot.md`, `gemini.md`, or `aider.md` inside individual skill directories. Validation rejects those obsolete duplicate adapters.

## Aider workflow activation

The installer writes a compact catalog to `AICODEREVIEW.md` and copies managed skill directories to `.aicodereview/skills/`.

Load only the workflow needed for the current task:

```text
/read .aicodereview/skills/code-review/SKILL.md
```

Then ask Aider to use `code-review`.

## Legacy migration

Older releases appended managed content to `.github/copilot-instructions.md`, `GEMINI.md`, and `CONVENTIONS.md`.

The CLI validates the marker pair, installs the replacement, then removes only the managed legacy section. User-owned content outside the markers remains unchanged.

## Use

```text
Use code-review to review my current changes.
Use security-audit on this pull request.
Use review-fixer to fix only safe and concrete findings.
Use release-review to check whether this build is ready to ship.
Use architecture-review to inspect dependency direction and layer violations.
Use test-writer to add tests grounded in the repository's current test style.
```

For Gemini CLI, run `/skills reload` after adding or updating workspace skills.

## Per-project context

```bash
cp templates/PROJECT_CONTEXT.md /path/to/project/PROJECT_CONTEXT.md
```

Document the actual stack, architecture, conventions, verification commands, and migration constraints. Skills read this file when present.

## Temporary shell maintenance commands

Until Phase 2B:

```bash
./update.sh --project /path/to/project
./list-installed.sh --project /path/to/project
./check-health.sh --project /path/to/project
```

## Uninstall

```bash
node bin/aicodereview.js uninstall --agent claude
node bin/aicodereview.js uninstall --agent aider --project /path/to/project
node bin/aicodereview.js uninstall --agent all --project /path/to/project
```

User-owned paths and configuration remain untouched.

## Validate and test

Cross-platform Node tests:

```bash
npm test
```

Shell compatibility tests:

```bash
npm run test:shell
```

GitHub Actions runs the Node CLI suite on Ubuntu, macOS, and Windows. Shell compatibility remains covered on Ubuntu and macOS.

## Design principles

- Inspect real files before making claims.
- Report production risks rather than personal style preferences.
- Rank findings by severity and include file and line references.
- Keep review workflows read-only unless the user explicitly requests changes.
- Prefer small, verifiable fixes over broad rewrites.
- Keep secrets, keys, signing files, private data, and `.env` values out of context files.
- Describe skills, rules, conventions, and hooks accurately instead of treating them as interchangeable.

## Roadmap

- **Phase 0:** Installation ownership, migration safety, native multi-agent support, and CI.
- **Phase 1:** Canonical workflow source, standardized metadata, generated Cursor rules, and selective Aider loading.
- **Phase 2A:** Cross-platform Node and TypeScript install, uninstall, validate, and generate commands.
- **Phase 2B:** Cross-platform list, health, update, release packaging, and retirement of runtime Bash/Python requirements.
- **Phase 3:** Optional hooks and behavioral evaluation repositories.

## Contributing

See `SKILL_GUIDE.md`.

## License

MIT
