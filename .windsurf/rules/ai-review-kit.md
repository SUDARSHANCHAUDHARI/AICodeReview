# AI Review Kit Rules

Use these rules when reviewing code, auditing security, explaining a repository, preparing release notes, or creating project context.

## Prompt Sources

Prefer the matching prompt in `prompts/`:

- `prompts/code-review.md`
- `prompts/security-audit.md`
- `prompts/codebase-explainer.md`
- `prompts/review-fixer.md`
- `prompts/android-review.md`
- `prompts/release-review.md`
- `prompts/pr-summary.md`
- `prompts/context-writer.md`

## Rules

- Inspect actual files before making claims.
- Read `PROJECT_CONTEXT.md`, `AGENTS.md`, README, and nearby tests when present.
- Review real risks, not taste.
- Keep findings severity-ranked and file/line referenced.
- Do not edit files, push, publish, or change repo settings unless explicitly asked.
