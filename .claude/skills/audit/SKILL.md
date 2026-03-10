---
name: audit
description: Run code quality audits (boundaries, dead code, drift, errors, idiomatic, names, TODOs, guidelines). Use when asked to audit, review code quality, or find issues in the codebase.
---

# Audit

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
| --- | --- |
| boundaries | [boundaries.md](reference/boundaries.md) |
| dead-code | [dead-code.md](reference/dead-code.md) |
| drift | [drift.md](reference/drift.md) |
| errors | [errors.md](reference/errors.md) |
| idiomatic | [idiomatic.md](reference/idiomatic.md) |
| names | [names.md](reference/names.md) |
| todo | [todo.md](reference/todo.md) |
| guidelines | [guidelines.md](reference/guidelines.md) |

All audit files (except guidelines) have a corresponding subagent prompt file (e.g., `boundaries-subagents.md`). Read those too when instructed by the audit file.

**If running all audits**: Execute sequentially. Present findings after each audit. At the end, provide a combined summary:

```markdown
## Combined Audit Summary

| Audit | Critical | High | Medium | Low |
| --- | --- | --- | --- | --- |
| Boundaries | X | X | X | X |
| Dead Code | X | X | X | X |
| ... |  |  |  |  |
| **Total** | X | X | X | X |
```
