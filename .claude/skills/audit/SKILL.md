---
name: audit
context: fork
description: Run code quality audits on the codebase. Detects issues across boundaries, dead code, state drift, errors, idiomatic usage, naming, TODOs, and guideline violations.
---

# Code Audit

Run targeted or comprehensive code quality audits.

## Available Audit Types

| Type | Detects |
|------|---------|
| `boundaries` | Layer violations, improper cross-module dependencies |
| `dead-code` | Unused exports, orphaned files, commented-out code, stale feature flags |
| `drift` | State sync issues, impossible states, boolean explosions |
| `errors` | Empty catch blocks, silent failures, inconsistent error handling |
| `idiomatic` | Anti-patterns, non-idiomatic framework usage |
| `names` | Vague identifiers, missing boolean prefixes, casing inconsistencies |
| `todo` | Stale TODOs, security-related debt, low-quality markers |
| `guidelines` | Violations of your project's coding guidelines |

## Workflow

### Step 1: Determine Audit Type

**Always ask the user what they want to audit.** Use `AskUserQuestion`:

- Question: "What would you like to audit?"
- Options:
  - **All audits** — "Run all 8 audit types sequentially"
  - **Boundaries** — "Layer violations, improper dependencies"
  - **Dead code** — "Unused exports, orphaned files, commented-out code"
  - **State drift** — "Impossible states, boolean explosions, duplicated state"
- If user picks "Other", present the remaining types: errors, idiomatic, names, todo, guidelines

### Step 2: Execute Audit

Read the corresponding audit file from this skill's directory and follow its instructions completely:

| Type | Read this file |
|------|---------------|
| boundaries | [boundaries.md](boundaries.md) |
| dead-code | [dead-code.md](dead-code.md) |
| drift | [drift.md](drift.md) |
| errors | [errors.md](errors.md) |
| idiomatic | [idiomatic.md](idiomatic.md) |
| names | [names.md](names.md) |
| todo | [todo.md](todo.md) |
| guidelines | [guidelines.md](guidelines.md) |

Some audit files reference additional subagent prompt files (e.g., `boundaries-subagents.md`). Read those too when instructed.

### If Running All Audits

Execute sequentially. After each audit completes, present its findings before starting the next. At the end, provide a combined summary:

```
## Combined Audit Summary

| Audit | Critical | High | Medium | Low |
|-------|----------|------|--------|-----|
| Boundaries | X | X | X | X |
| Dead Code | X | X | X | X |
| ... | | | | |
| **Total** | X | X | X | X |
```
