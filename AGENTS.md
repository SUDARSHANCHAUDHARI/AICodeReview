# AICodeReview — Agent Context

This repo is a skill pack for AI coding agents. It provides code review, security audit, and project utility workflows that work across Claude Code, OpenAI Codex, Cursor, GitHub Copilot, Gemini CLI, and Aider.

## What This Repo Contains

- `skills/` — one folder per skill. Each folder has a `SKILL.md` (shared prompt) and `agents/` configs for each supported agent.
- `install.sh` — installs skills to the correct location for each agent.
- `uninstall.sh` — removes installed skills cleanly, preserving existing content.
- `scripts/validate.sh` — validates all skills have required files and are wired into the installer.
- `templates/PROJECT_CONTEXT.md` — template users copy into their own repos to give AI agents repo-specific context.
- `examples/` — filled-in examples of `PROJECT_CONTEXT.md` for Android and web projects.
- `docs/` — usage and customisation guides.

## Skills

| Skill | Purpose |
|---|---|
| `code-review` | Review code changes for bugs, security, performance, and missing tests |
| `security-audit` | Threat-model driven security and privacy audit |
| `codebase-explainer` | Explain repo architecture, modules, and data flow |
| `review-fixer` | Apply safe, concrete fixes from review findings |
| `android-review` | Android/Kotlin/KMP/Compose-specific review |
| `ios-review` | iOS/macOS Swift/SwiftUI-specific review |
| `web-review` | React/Next.js/TypeScript-specific review |
| `release-review` | Release readiness check before shipping |
| `pr-summary` | Write concise PR descriptions from local changes |
| `context-writer` | Create or update `PROJECT_CONTEXT.md` for a repo |
| `changelog-writer` | Generate CHANGELOG entries from git commits |
| `dependency-audit` | Check for outdated, vulnerable, or risky dependencies |
| `agent-config-review` | Review AI agent config files for quality and security |
| `backend-review` | REST/GraphQL API, DB queries, auth, error handling, service-layer review |
| `performance-review` | Latency, memory, N+1, caching, and rendering bottleneck review |
| `accessibility-audit` | WCAG 2.1 AA audit: semantics, keyboard, ARIA, contrast, mobile |
| `database-review` | Schema, migrations, indexes, query efficiency, and data integrity |
| `test-writer` | Write unit, integration, and snapshot tests matching existing test style |
| `kmp-review` | Kotlin Multiplatform: expect/actual, shared logic, platform-specific code |
| `docker-review` | Dockerfile and Compose: layers, secrets, base images, health checks |
| `ci-review` | CI/CD pipeline: secrets, caching, test gating, failure modes |
| `api-design-review` | API contract: naming, versioning, auth, error shapes, idempotency |
| `flutter-review` | Flutter/Dart: widget lifecycle, build perf, platform channels, release |
| `refactor-planner` | Plan safe incremental refactors with blast radius and rollback steps |
| `architecture-review` | Dependency direction, circular deps, god modules, coupling, layer violations |
| `code-smell-detector` | God classes, long methods, feature envy, dead code, magic numbers |
| `error-handling-review` | Silent catches, missing UI errors, retry without backoff, untyped errors |
| `graphql-review` | Schema design, resolver N+1, field-level auth, depth limits, breaking changes |
| `react-native-review` | JS thread, bridge usage, FlatList, memory leaks, CodePush, deep link security |
| `tech-debt-audit` | TODO/FIXME scan, deprecated APIs, untested critical paths, dead feature flags |
| `onboarding-writer` | Generate ONBOARDING.md from real repo inspection |

## Supported Agents

| Agent | Install target |
|---|---|
| Claude Code | `~/.claude/skills/` |
| OpenAI Codex | `~/.codex/skills/` |
| Cursor | `<project>/.cursor/rules/` |
| GitHub Copilot | `<project>/.github/copilot-instructions.md` |
| Gemini CLI | `<project>/GEMINI.md` |
| Aider | `<project>/CONVENTIONS.md` |

## Install

```bash
./install.sh                                          # claude + codex (default)
./install.sh --agent all --project /path/to/project  # all agents
```

## Validate

```bash
./scripts/validate.sh
```

## Conventions

- Each skill must have `SKILL.md` with valid YAML frontmatter (`name`, `description`).
- Each skill must have all five agent files: `openai.yaml`, `cursor.mdc`, `copilot.md`, `gemini.md`, `aider.md`.
- Every new skill must be added to the `skills` array in `install.sh` and `uninstall.sh`.
- Never commit secrets, signing material, `.env` values, or private customer data.
- Run `./scripts/validate.sh` before opening a PR.
