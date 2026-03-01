# State Drift Audit

Detect and fix state synchronization issues, impossible states, and state management anti-patterns.

## What This Command Detects

State drift occurs when application state becomes inconsistent, duplicated, or poorly modeled. This leads to subtle bugs where the UI shows stale data, impossible combinations occur, or changes in one place don't propagate to another.

### Categories of State Drift

| Category | Description |
|----------|-------------|
| **Boolean Explosion** | Multiple booleans creating 2^n states, many impossible |
| **Magic Strings** | String literals for status/state instead of enums/constants |
| **Duplicated State** | Same data stored in multiple locations |
| **Derived State Stored** | Computed values stored instead of calculated |
| **Impossible States** | "Bags of optionals" instead of discriminated unions |
| **Status Mismatches** | Database enums not matching code enums |
| **Missing State Machines** | Ad-hoc state transitions instead of explicit FSMs |
| **Single Source of Truth Violations** | Multiple authoritative sources for same data |

## Phase 1: Discover the Codebase

1. **Identify the tech stack**:
   - Frontend framework (React, Vue, Svelte, etc.)
   - State management (Redux, Zustand, Pinia, MobX, Context, etc.)
   - Backend framework (Laravel, Express, Rails, etc.)
   - Database (Postgres, MySQL, SQLite, etc.)
   - ORM/Query builder (Eloquent, Prisma, Drizzle, TypeORM, etc.)

2. **Map state locations**:
   - Frontend state files (stores, reducers, atoms, signals)
   - API response types
   - Database schemas/migrations
   - Shared types between frontend/backend

## Phase 2: Parallel Audit (Using Subagents)

**Launch 5 subagents in parallel** using `Agent` with `subagent_type=Explore`. See [drift-subagents.md](drift-subagents.md) for detailed prompts.

| Subagent | Focus |
|----------|-------|
| 1 | Boolean explosion & impossible states (bags of optionals) |
| 2 | Magic strings & status mismatches (db vs code enums) |
| 3 | Duplicated & derived state (stored instead of computed) |
| 4 | State machine opportunities (ad-hoc transitions) |
| 5 | Single source of truth violations (multiple authoritative sources) |

Pass tech stack and state locations from Phase 1 to each subagent.

---

## Phase 3: Prioritize Findings

Categorize by severity:

| Priority | Criteria | Examples |
|----------|----------|----------|
| **P1 Critical** | Causes bugs now | Impossible states reached, data corruption |
| **P2 High** | Will cause bugs | Missing state machine, race conditions likely |
| **P3 Medium** | Tech debt | Magic strings, derived state stored |
| **P4 Low** | Code quality | Minor duplication, naming inconsistencies |

## Phase 4: Present Findings

```markdown
## State Drift Audit Results

### Summary
- X impossible state patterns found
- X magic string usages
- X duplicated state instances
- X state machine opportunities
- X source of truth violations

### P1 Critical - Fix Immediately
| Issue | Location | Pattern | Fix |
|-------|----------|---------|-----|
| ... | file:line | ... | ... |

### P2 High - Fix Soon
...

### P3 Medium - Plan to Fix
...

### P4 Low - Nice to Have
...
```

## Phase 5: Fix Options

Present options to the user:

1. **Fix P1 Critical only** - Address bugs that are likely happening now
2. **Fix P1 + P2** - Critical and high-priority issues
3. **Fix all automatically fixable** - Magic strings, simple discriminated unions
4. **Generate refactor plan** - For state machine implementations
5. **Report only** - Just the audit, no changes

### Automatic Fixes Available

These patterns can be fixed automatically:

- Magic strings → enum/const definitions
- Simple boolean pairs → discriminated union
- Obvious derived state → useMemo/computed
- Duplicate type definitions → single export

### Manual Refactors Required

These need human decision-making:

- State machine design (what are the valid transitions?)
- Source of truth designation (which layer owns the data?)
- Complex discriminated unions (what are all the states?)

## Notes

- Focus on `src/`, `app/`, `lib/` - skip `node_modules/`, `vendor/`
- Check recent changes first: `git diff --name-only HEAD~20`
- Some "duplication" is intentional (denormalization for performance)
- Ask before removing what might be intentional caching
