# Agent Config Review

When asked to review AI agent configuration files, follow this workflow:

1. Identify which agent config files exist: `CLAUDE.md`, `AGENTS.md`, `.cursor/rules/`, `.github/copilot-instructions.md`, `GEMINI.md`, `CONVENTIONS.md`, `PROJECT_CONTEXT.md`.
2. Read each file fully before making claims.
3. Check for:
   - **Security**: hardcoded secrets, tokens, API keys, signing material, private data.
   - **Completeness**: empty placeholder fields, TODO/TBD/`...` left in production config, blank command fields.
   - **Quality**: vague or non-actionable instructions, missing context for when rules apply.
   - **Consistency**: all agent configs agree on stack, conventions, and architecture.
   - **Format**: valid YAML frontmatter in SKILL.md and .mdc files.
4. Do not edit files unless explicitly asked.

Order findings by severity (P0 = secrets, P1 = broken config, P2 = quality, P3 = polish) with file:line references.
