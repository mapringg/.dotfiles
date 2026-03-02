---
name: faster
description: Unified skill hub — audit, CI, init, ship, and think. Asks drill-down questions to route to the right workflow.
---

# Faster

One skill to rule them all. Ask the user what they need, then drill down.

## Instructions

**Always ask the user what they want to do:**

- **Question**: "What do you want to do?"
- **Options**:
  1. **Audit** — "Run code quality audits (boundaries, dead code, drift, errors, naming, etc.)"
  2. **Fix CI** — "Diagnose and fix failing GitHub Actions"
  3. **Init** — "Set up project rules or manage init helpers"
  4. **Ship** — "Run tests, clean up, and commit your work"
  5. **Think** — "Research best practices or refine a vague idea into a spec"

## After User Chooses

### Audit

Ask a follow-up:

- **Question**: "What would you like to audit?"
- **Options**:
  1. **All audits** — "Run all 8 audit types sequentially"
  2. **Boundaries** — "Layer violations, improper dependencies"
  3. **Dead code** — "Unused exports, orphaned files, commented-out code"
  4. **State drift** — "Impossible states, boolean explosions, duplicated state"
  5. **Errors** — "Empty catches, lost exception chains, unhandled promises"
  6. **Idiomatic** — "Non-idiomatic language and framework usage"
  7. **Names** — "Vague, inconsistent, or confusing identifier names"
  8. **TODOs** — "Stale TODOs, missing context, forgotten FIXMEs"
  9. **Guidelines** — "Audit against project coding guidelines"

Then read the corresponding audit reference file and follow its instructions:

| Type | Read this file |
|------|---------------|
| boundaries | [boundaries.md](reference/audit/boundaries.md) |
| dead-code | [dead-code.md](reference/audit/dead-code.md) |
| drift | [drift.md](reference/audit/drift.md) |
| errors | [errors.md](reference/audit/errors.md) |
| idiomatic | [idiomatic.md](reference/audit/idiomatic.md) |
| names | [names.md](reference/audit/names.md) |
| todo | [todo.md](reference/audit/todo.md) |
| guidelines | [guidelines.md](reference/audit/guidelines.md) |

Some audit files reference additional subagent prompt files (e.g., `boundaries-subagents.md`). Read those too when instructed.

**If running all audits**: Execute sequentially. Present findings after each audit. At the end, provide a combined summary:

```
## Combined Audit Summary

| Audit | Critical | High | Medium | Low |
|-------|----------|------|--------|-----|
| Boundaries | X | X | X | X |
| Dead Code | X | X | X | X |
| ... | | | | |
| **Total** | X | X | X | X |
```

### Fix CI

Read and follow [gha.md](reference/gha.md).

### Init

Ask a follow-up:

- **Question**: "What would you like to do?"
- **Options**:
  1. **Initialize project** — "Detect your stack and set up all framework rules"
  2. **Create new init** — "Add a helper for a framework we don't support yet"
  3. **Update an init** — "Add learnings, research, or new content to an existing init helper"
  4. **Reconcile** — "Sync local project rules with master init helpers (two-way)"

Then read the corresponding file and follow its instructions:

| Choice | Read this file |
|--------|---------------|
| Initialize project | [setup.md](reference/init/setup.md) |
| Create new init | [add.md](reference/init/add.md) |
| Update an init | [update.md](reference/init/update.md) |
| Reconcile | [reconcile.md](reference/init/reconcile.md) |

### Ship

Ask a follow-up:

- **Question**: "What do you want to do?"
- **Options**:
  1. **Full pipeline** — "Run tests, clean up false starts, then commit"
  2. **Skip tests** — "Clean up and commit without running tests"
  3. **Just commit** — "Generate a commit message and commit"
  4. **Review changes** — "Review a PR or diff for bugs, security, and guidelines"

Then execute the chosen steps:

| Choice | Steps |
|--------|-------|
| Full pipeline | [tests.md](reference/ship/tests.md) → [finalize.md](reference/ship/finalize.md) → [commit.md](reference/ship/commit.md) |
| Skip tests | [finalize.md](reference/ship/finalize.md) → [commit.md](reference/ship/commit.md) |
| Just commit | [commit.md](reference/ship/commit.md) |
| Review changes | [review.md](reference/ship/review.md) |

### Think

Ask a follow-up:

- **Question**: "What kind of thinking?"
- **Options**:
  1. **Product research** — "UX patterns, user behavior, design best practices for your product"
  2. **Technical research** — "Security, performance, testing best practices for your stack"
  3. **Refine an idea** — "Turn a vague idea into a concrete spec through interviewing"
  4. **Debug** — "Systematically diagnose and fix a bug or broken behavior"

Then read the corresponding file and follow its instructions:

| Choice | Read this file |
|--------|---------------|
| Product research | [product.md](reference/think/product.md) |
| Technical research | [stack.md](reference/think/stack.md) |
| Refine an idea | [interview.md](reference/think/interview.md) |
| Debug | [debug.md](reference/think/debug.md) |
