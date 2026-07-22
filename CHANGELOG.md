# Changelog

All notable changes to AICodeReview will be documented here.

## Unreleased

### Phase 3 hooks and behavioral evaluations

- Added optional repository lifecycle hooks for GitHub Copilot and Gemini CLI using their documented hook formats.
- Added cross-platform hook installation, status, safe removal, ownership markers, and unmanaged-conflict backups.
- Added a deterministic Node hook runner for session-start and agent-stop events.
- Added local lifecycle reports containing Git status and `git diff --check` results without claiming to perform an AI review.
- Added a shareable Gemini extension with extension-relative hook commands.
- Added three behavioral evaluation fixtures: hardcoded secret exposure, missing object-level authorization, and a safe false-positive control.
- Added manifest validation and result scoring for true positives, false positives, false negatives, precision, recall, and severity accuracy.
- Added cross-platform tests for hook configuration, JSON-only hook output, safe uninstall, fixture validation, and scoring.
- Added hook and evaluation assets to the npm package and release validation.

### Phase 2 cross-platform CLI

- Added a complete TypeScript CLI for install, uninstall, list, health, update, validation, and metadata generation.
- Replaced the npm entrypoint's Bash delegation with the compiled Node runtime.
- Preserved backward-compatible flag-only usage while adding explicit commands.
- Ported ownership markers, conflict backups, migration validation, all-agent preflight, native skill installation, generated Cursor rules, and selective Aider loading to Node.js.
- Added transactional directory, file, and ownership-marker replacement with rollback after failed operations.
- Added drift-aware inventory, health checks, and managed update detection.
- Removed Bash and Python files from the published npm runtime package.
- Added package-content validation and a guarded prepublish lifecycle.
- Added Ubuntu, macOS, and Windows Node CLI jobs.

### Phase 1 skill standardization

- Migrated all 31 `agents/openai.yaml` files to the nested `interface:` structure.
- Required quoted metadata strings, 25–64 character short descriptions, and `$skill-name` in every default prompt.
- Added deterministic metadata generation and check mode.
- Removed 124 manually maintained Cursor, Copilot, Gemini, and Aider prompt copies.
- Generated Cursor rules directly from canonical `SKILL.md` content.
- Added a compact Aider workflow catalog and selective skill loading.

### Phase 0 native integrations and foundation hardening

- Replaced combined Copilot and Gemini instructions with native skills.
- Added native OpenCode support and safe Aider activation.
- Added ownership markers, dynamic discovery, backups, marker validation, migration safety, all-agent preflight, and behavioral safety tests.
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
