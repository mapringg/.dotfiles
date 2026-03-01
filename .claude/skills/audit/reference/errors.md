# Errors Audit

Detect error handling inconsistencies, anti-patterns, and silent failures.

## The Core Problem

Error handling inconsistency creates unpredictable failure modes and debugging nightmares. "Catch and Do Nothing" is among the most common anti-patterns, silently swallowing errors that should surface.

## What This Command Detects

| Pattern | Description |
|---------|-------------|
| **Empty Catch Blocks** | Exceptions caught but ignored |
| **Overly Broad Catches** | Catching Exception/Throwable/BaseException |
| **Lost Exception Chains** | Re-throwing without original cause |
| **Promises Without Catch** | Unhandled promise rejections |
| **Inconsistent Error Strategy** | Mixed approaches (exceptions vs result types vs error codes) |
| **Pointless Rethrow** | Catch only to rethrow unchanged |

## Phase 1: Discover the Codebase

1. **Identify the tech stack**:
   - Language (TypeScript, Python, Java, Go, PHP, Rust, etc.)
   - Error handling idioms (exceptions, Result types, error codes)
   - Async patterns (Promises, async/await, callbacks)

2. **Identify error handling conventions**:
   - Custom error classes
   - Error logging patterns
   - Global error handlers

## Phase 2: Parallel Audit (Using Subagents)

**Launch 5 subagents in parallel** using `Agent` with `subagent_type=Explore`. See [errors-subagents.md](errors-subagents.md) for detailed prompts.

| Subagent | Focus |
|----------|-------|
| 1 | Empty & broad catch blocks (silent failures) |
| 2 | Lost exception chains & pointless rethrows |
| 3 | Promise & async error handling (floating promises, missing catch) |
| 4 | Error strategy consistency (mixed exceptions/result types/null returns) |
| 5 | Error message quality (generic messages, missing context, logging gaps) |

Pass tech stack and error handling conventions from Phase 1 to each subagent.

---

## Phase 3: Prioritize Findings

| Priority | Pattern | Rationale |
|----------|---------|-----------|
| **P1 Critical** | Empty catch with data operations | Silent data loss |
| **P1 Critical** | Floating promises in critical paths | Unhandled failures |
| **P2 High** | Empty catch (general) | Masks all failures |
| **P2 High** | Bare except / catch Throwable | Catches system errors |
| **P2 High** | Promise without catch | Unhandled rejection |
| **P2 High** | Lost exception chain | Debugging nightmare |
| **P3 Medium** | Pointless rethrow | Noise without value |
| **P3 Medium** | Inconsistent error strategy | Maintenance burden |
| **P4 Low** | Generic error message | Debugging hindrance |

## Phase 4: Present Findings

```markdown
## Errors Audit Results

### Summary
- X empty catch blocks
- X overly broad catches
- X lost exception chains
- X promises without catch
- X error strategy inconsistencies

### P1 Critical - Fix Immediately
| Issue | Location | Pattern | Fix |
|-------|----------|---------|-----|
| ... | file:line | ... | ... |

### P2 High - Fix Soon
...
```

## Phase 5: Fix Options

1. **Auto-fixable**:
   - Add `// intentionally ignored` comments to legitimate empty catches
   - Add `.catch(console.error)` to floating promises

2. **Semi-auto** (generate fix):
   - Add cause to re-thrown exceptions
   - Convert pointless rethrow to let exception propagate

3. **Manual review required**:
   - Migrate error strategy (exceptions → Result types)
   - Add proper error handling to empty catches

## Recommended Fixes Reference

| Anti-Pattern | Fix |
|--------------|-----|
| Empty catch | Log error or propagate; use explicit suppression if intentional |
| Lost chain | Pass original as cause: `new Error(msg, { cause })` |
| Generic catch | Catch specific types; use multiple catch blocks |
| No Promise catch | Add `.catch()` or use try/catch with await |
| Inconsistent strategy | Establish team convention; migrate gradually |
| Generic message | Include operation, input, and failure reason |

## Notes

- Some empty catches are legitimate (interrupt handling, cleanup)
- Error strategy migration should be gradual, module by module
- Consider adding global unhandled rejection handler as safety net
