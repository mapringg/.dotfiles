
# TODOs Audit

Detect and prioritize technical debt markers, stale TODOs, and forgotten FIXMEs.

## The Core Problem

TODOs have an average lifespan of **166 days**. Nearly **47% are low-quality**, lacking actionable information. Without systematic tracking, debt accumulates invisibly.

## What This Command Detects

| Pattern | Description |
|---------|-------------|
| **Stale TODOs** | Old markers that should be resolved or removed |
| **Security TODOs** | Debt related to auth, validation, encryption |
| **Bug Markers** | FIXME, BUG, XXX indicating known defects |
| **Missing Context** | TODOs without explanation or owner |
| **Closed Issue References** | TODOs pointing to resolved issues |
| **High-traffic Area Debt** | TODOs in critical code paths |

## Marker Types & Severity

| Marker | Meaning | Default Priority |
|--------|---------|------------------|
| `TODO` | Planned improvement | Medium |
| `FIXME` | Known bug, needs fix | High |
| `HACK` | Temporary workaround | High |
| `XXX` | Dangerous/problematic | High |
| `BUG` | Confirmed defect | Critical |
| `OPTIMIZE` | Performance issue | Medium |
| `REFACTOR` | Code quality debt | Low |
| `REVIEW` | Needs code review | Medium |
| `NOTE` | Documentation/context | Info |
| `DEPRECATED` | Scheduled for removal | Medium |

## Phase 1: Discover the Codebase

1. **Identify issue tracker**:
   - GitHub Issues (#123)
   - Jira (PROJ-123)
   - Linear (LIN-123)
   - Other patterns

2. **Identify code ownership**:
   - CODEOWNERS file
   - git blame for authorship
   - Team/module boundaries

## Phase 2: Parallel Audit (Using Subagents)

**Launch 5 subagents in parallel** using `Agent` with `subagent_type=Explore`. See [todo-subagents.md](todo-subagents.md) for detailed prompts.

| Subagent | Focus |
|----------|-------|
| 1 | TODO inventory & age analysis (git blame scoring) |
| 2 | Security & bug markers (critical priority keywords) |
| 3 | Issue tracker integration (check if referenced issues are closed) |
| 4 | Quality & context analysis (missing explanation, vague actions) |
| 5 | Prioritization & categorization (scoring formula, actionable groups) |

Pass issue tracker patterns and code ownership from Phase 1 to each subagent.

## Phase 3: Generate Report

### Summary Statistics
```markdown
## TODO Audit Summary

### Overview
- **Total markers found**: X
- **Average age**: X days
- **Oldest marker**: X days old (file:line)

### By Type
| Type | Count | Avg Age |
|------|-------|---------|
| TODO | X | X days |
| FIXME | X | X days |
| HACK | X | X days |
| BUG | X | X days |

### By Priority
| Priority | Count | Action |
|----------|-------|--------|
| Critical | X | Resolve now |
| High | X | Plan soon |
| Medium | X | Add to backlog |
| Low | X | Review/delete |

### Health Score
Technical Debt Index: X/100
(Lower is better - based on count, age, and severity)
```

## Phase 4: Fix Options

1. **Create Issues**:
   - Generate GitHub/Jira issues from high-priority TODOs
   - Link issues back to code location

2. **Delete Stale**:
   - Remove TODOs referencing closed issues
   - Remove very old TODOs (>2 years) with confirmation

3. **Add Context**:
   - Interactive prompt to add missing explanations
   - Add owner attribution

4. **Generate Report**:
   - Export to markdown/CSV for team review
   - Include in sprint planning

## Recommended Actions by Priority

| Priority | Action |
|----------|--------|
| **Critical** | Resolve immediately or create P1 issue |
| **High** | Create issue, assign to sprint |
| **Medium** | Add to backlog with context |
| **Low** | Delete if vague, document if legitimate |
| **Info (NOTE)** | Review for accuracy, convert to docs if valuable |

## Notes

- Some TODOs are legitimate long-term items (document the reason)
- README TODOs have different lifecycle than code TODOs
- Skip vendor/, node_modules/, generated/ directories
- Consider adding pre-commit hook to require TODO context
- Run this audit monthly to prevent debt accumulation
