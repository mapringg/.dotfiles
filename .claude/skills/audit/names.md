
# Names Audit

Detect vague, inconsistent, and confusing identifier names that hurt code comprehension.

## The Core Problem

Research by Butler et al. found **statistically significant associations** between flawed identifier names and bugs. Naming quality directly impacts code comprehension and defect rates.

## What This Command Detects

| Pattern | Description |
|---------|-------------|
| **Vague Generic Names** | data, info, item, thing, handler, manager |
| **Single-letter Variables** | Non-idiomatic use of i, j, x outside loops/math |
| **Missing Boolean Prefixes** | `loading` instead of `isLoading` |
| **Negative Booleans** | `isNotDisabled`, `hasNoErrors` causing double-negation |
| **Casing Inconsistency** | Mixed camelCase/snake_case in same codebase |
| **Abbreviation Inconsistency** | Both `btn` and `button` in same codebase |

## Phase 1: Discover the Codebase

1. **Identify the tech stack**:
   - Language (determines casing conventions)
   - Framework (React props, Express req/res, etc.)
   - Domain (math, networking, graphics)

2. **Infer naming conventions**:
   - Dominant casing for variables, functions, classes, constants
   - Common abbreviations used
   - Domain-specific terminology

## Phase 2: Parallel Audit (Using Subagents)

**Launch 5 subagents in parallel** using `Agent` with `subagent_type=Explore`. See [names-subagents.md](names-subagents.md) for detailed prompts.

| Subagent | Focus |
|----------|-------|
| 1 | Vague generic names (data, info, item, handler, etc.) |
| 2 | Single-letter variables outside idiomatic contexts |
| 3 | Boolean naming (missing prefixes, negative booleans) |
| 4 | Casing inconsistency (mixed conventions in same codebase) |
| 5 | Abbreviation inconsistency (both `btn` and `button`) |

Pass tech stack and naming conventions from Phase 1 to each subagent.

## Phase 3: Prioritize Findings

| Priority | Issue | Rationale |
|----------|-------|-----------|
| **P1 Critical** | Single-letter in public API | Unusable API |
| **P1 Critical** | Negative boolean in conditionals | Logic errors |
| **P2 High** | Vague names in public APIs | Documentation debt |
| **P2 High** | Missing boolean prefix | Readability |
| **P2 High** | Ambiguous abbreviations | Multiple meanings |
| **P3 Medium** | Abbreviation inconsistency | Maintenance burden |
| **P3 Medium** | Casing inconsistency within file | Style debt |
| **P4 Low** | Vague names in small local scopes | Minor readability |

## Phase 4: Present Findings

```markdown
## Names Audit Results

### Summary
- X vague generic names
- X single-letter variables (outside idioms)
- X boolean naming issues
- X casing inconsistencies
- X abbreviation inconsistencies

### P1 Critical
| Issue | Location | Current | Suggested |
|-------|----------|---------|-----------|
| ... | file:line | ... | ... |

### P2 High
...
```

## Phase 5: Fix Options

1. **Auto-fixable**:
   - Add boolean prefixes: `loading` → `isLoading`
   - Fix casing: `user_name` → `userName`
   - Standardize abbreviations (with confirmation)

2. **Semi-auto** (generate renames):
   - Rename vague variables with context-aware suggestions
   - Convert negative booleans to positive form

3. **Manual review required**:
   - Public API renames (breaking changes)
   - Domain-specific terminology decisions

## Recommended Fixes Reference

| Issue | Fix |
|-------|-----|
| `data` | `userData`, `configData`, `responseData` |
| `info` | `userInfo`, `metaInfo`, `displayInfo` |
| `handler` | `formSubmitHandler`, `errorHandler` |
| `loading` | `isLoading` |
| `isNotDisabled` | `isEnabled` |
| `hasNoErrors` | `isValid` or `!hasErrors` |

## Notes

- Some vagueness is acceptable in very small scopes
- Domain experts may have valid abbreviation preferences
- Renaming public APIs requires deprecation cycle
- Run formatter/linter after bulk renames
