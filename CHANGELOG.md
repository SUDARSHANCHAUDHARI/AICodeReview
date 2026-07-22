# Changelog

All notable changes to AICodeReview will be documented here.

## Unreleased

### Phase 2 cross-platform CLI

- Added a complete TypeScript CLI for install, uninstall, list, health, update, validation, and metadata generation.
- Replaced the npm entrypoint's Bash delegation with the compiled Node runtime.
- Preserved backward-compatible flag-only usage while adding explicit commands.
- Ported ownership markers, conflict backups, migration validation, all-agent preflight, native skill installation, generated Cursor rules, and selective Aider loading to Node.js.
- Added transactional directory, file, and ownership-marker replacement with rollback after failed operations.
- Added drift-aware inventory and health checks across every supported integration.
- Added managed update detection, including selective Aider installations without a catalog file.
- Removed Bash and Python files from the published npm runtime package.
- Added package-content validation and a guarded prepublish lifecycle.
- Added Node behavior tests for installation, migration, orphan markers, backups, inventory, health, update, and ownership-aware uninstall.
- Added Ubuntu, macOS, and Windows Node CLI jobs while retaining repository-only shell compatibility checks on Ubuntu and macOS.

### Phase 1 skill standardization

- Migrated all 31 `agents/openai.yaml` files to the nested `interface:` structure.
- Required quoted metadata strings, 25–64 character short descriptions, and `$skill-name` in every default prompt.
- Added deterministic metadata generation and check mode so stale metadata fails validation and installation.
- Removed 124 manually maintained Cursor, Copilot, Gemini, and Aider prompt copies.
- Generated Cursor rules directly from canonical `SKILL.md` content.
- Added a compact Aider workflow catalog and installed canonical skill directories under `.aicodereview/skills/` for selective `/read` loading.
- Added health and inventory checks for generated Cursor rules, the Aider catalog, and selective Aider skill directories.
- Added behavioral tests for generation, multi-rule Cursor installation, compact Aider output, selective Aider installation, and ownership-aware cleanup.

### Phase 0B native agent integrations

- Replaced combined GitHub Copilot instructions with native project skills under `.github/skills/`.
- Replaced persistent Gemini context with native workspace skills under `.gemini/skills/`.
- Added native OpenCode support under `.opencode/skills/`.
- Added a managed Aider catalog and safe `.aider.conf.yml` activation.
- Added safe migration from legacy Copilot, Gemini, and Aider sections while preserving user content.
- Added an all-agent preflight gate to prevent partial installations.

### Phase 0A foundation hardening

- Replaced duplicated hard-coded skill arrays with dynamic discovery.
- Added ownership markers for native skill directories and generated files.
- Changed forced installation so unmanaged conflicts are backed up instead of deleted.
- Changed uninstall so unmanaged paths are preserved.
- Added strict marker validation, atomic managed-section replacement, and expanded health checks.
- Added Ubuntu and macOS validation and behavioral safety tests.
- Removed the unpublished Homebrew formula stub.

### Existing unreleased work

- Restructured from Codex-only workflows to agent-agnostic skills.
- Added 31 review, audit, explanation, generation, and planning workflows.
- Added project-context templates, examples, issue templates, and contributor guidance.

## v0.1.0

- Initial skill pack scaffold.
- Added review, security audit, explanation, fixer, Android, release, pull request summary, and context-writer skills.
- Added project context templates and examples.
- Added local validation script.
