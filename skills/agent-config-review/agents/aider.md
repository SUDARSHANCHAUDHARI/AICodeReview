## Agent Config Review Convention

When asked to review AI agent config files:

1. Read CLAUDE.md, AGENTS.md, .cursor/rules/, .github/copilot-instructions.md, GEMINI.md, CONVENTIONS.md, and PROJECT_CONTEXT.md.
2. Check for secrets or tokens (P0 — must fix immediately).
3. Check for empty placeholder fields, TODO/TBD left in, blank command lines (P1).
4. Check for vague non-actionable instructions (P2).
5. Check all agent configs are consistent with each other (P2).
6. Verify valid YAML frontmatter in SKILL.md and .mdc files.
7. Do not edit files unless explicitly asked.
