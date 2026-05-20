---
name: agent-config-review
description: Use when reviewing AI agent configuration files for quality, completeness, security, and consistency. Covers CLAUDE.md, AGENTS.md, .cursor/rules/, copilot-instructions.md, GEMINI.md, CONVENTIONS.md, and PROJECT_CONTEXT.md.
---

# Agent Config Review

## Workflow

1. Identify which agent config files exist in the repo.
2. Read each file fully before making any claims.
3. Review for the issues listed below.
4. Do not edit files unless explicitly asked.

## Files To Check

| File | Agent |
|---|---|
| `CLAUDE.md` / `.claude/CLAUDE.md` | Claude Code |
| `AGENTS.md` | Codex / multi-agent |
| `.cursor/rules/*.mdc` | Cursor |
| `.github/copilot-instructions.md` | GitHub Copilot |
| `GEMINI.md` | Gemini CLI |
| `CONVENTIONS.md` | Aider |
| `PROJECT_CONTEXT.md` | All (project memory) |

## What To Check

### Security
- No hardcoded secrets, API keys, tokens, passwords, or private keys.
- No signing material, keystore paths with credentials, or `.env` values.
- No private customer data, internal URLs, or proprietary architecture details that should not be committed.

### Completeness
- No empty placeholder fields (e.g. `- Build:` with no value, `- Users:` with no value).
- No `TODO`, `FIXME`, `TBD`, `...`, or `<fill this in>` left in production config.
- Commands sections have real runnable commands, not blank lines.
- Known Risk Areas and Active Migrations are not empty unless genuinely not applicable.

### Quality
- Instructions are concrete and actionable — not vague ("be helpful", "write good code").
- Descriptions tell the agent *when* to apply a rule, not just *what* the rule is.
- No contradictory instructions within or across config files.
- No redundant rules repeated verbatim across multiple files.

### Consistency
- Agent configs agree on stack, conventions, and architecture.
- `PROJECT_CONTEXT.md` matches what the actual code does (spot-check key claims).
- Skill trigger descriptions match actual skill behavior.

### Format
- `SKILL.md` files have valid YAML frontmatter with `name` and `description`.
- Cursor `.mdc` files have valid frontmatter (`description`, `globs`, `alwaysApply`).
- Markdown is valid and renders correctly (no broken code fences, unmatched backticks).

## Output

```markdown
## Agent Config Findings

**[P0]** `CLAUDE.md:12` - Hardcoded API key
Exact issue, why it matters, and fix direction.

**[P1]** `PROJECT_CONTEXT.md:38` - Empty Commands section
All command fields are blank — agent cannot run builds or tests.

**[P2]** `.cursor/rules/code-review.mdc` - Vague instruction
"Write good code" gives Cursor nothing actionable. Replace with specific checks.

## Positive Notes

- ...

## Summary

Overall config health and highest-priority fix.
```

Severity guide:
- `P0`: secrets or data that must be removed immediately.
- `P1`: empty/broken config that causes the agent to fail or hallucinate.
- `P2`: quality issue that degrades review accuracy.
- `P3`: polish — redundancy, minor wording, optional improvements.
