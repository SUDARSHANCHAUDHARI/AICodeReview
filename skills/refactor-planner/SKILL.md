---
name: refactor-planner
description: Use when planning a refactor: identify blast radius, sequence steps safely, define rollback strategy, and break the work into independently mergeable increments.
---

# Refactor Planner

## Workflow

1. Understand the refactor goal: what is changing and why.
2. Read the files involved — do not guess at structure or dependencies.
3. Identify the blast radius: what else will break or need updating.
4. Sequence the work into safe, independently testable increments.
5. Define a rollback strategy for each step.
6. Do not make changes — produce a plan for the user to review first.

## What To Produce

### 1. Current State Summary
- What the code does now.
- Why it needs to change (the stated goal).
- What is risky or unclear about the current structure.

### 2. Blast Radius
- Files and modules directly affected.
- Files and modules indirectly affected (callers, tests, config).
- Public API surface changes (if any): breaking changes for callers or downstream consumers.
- Database/schema changes required (if any).
- Build/config changes required (if any).

### 3. Incremental Plan
Each increment must:
- Leave the codebase in a buildable, testable state.
- Be independently reviewable and mergeable (feature-flagged if needed).
- Have a clear verify step.

Format:
```
Step 1: [title]
  What: [specific change]
  Why first: [dependency reason]
  Verify: [how to confirm this step is correct]
  Rollback: [how to undo if needed]

Step 2: ...
```

### 4. Risks & Unknowns
- What could go wrong at each step.
- What needs a decision before starting.
- What requires load/performance testing after the change.

### 5. Recommendation
- Estimated complexity (small / medium / large).
- Whether a feature flag is needed.
- Whether a DB migration is involved and how to sequence it relative to the code change.
- Whether to do this all at once or spread across multiple PRs.

## Rules

- Do not suggest doing everything in one PR if the change is large.
- Do not suggest deleting old code in the same step as adding new code — separate the steps.
- Always call out breaking API changes explicitly.
- If the goal is unclear, ask before planning.
