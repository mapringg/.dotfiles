---
name: debug
description: Systematically diagnose and fix bugs. Use when the user reports a bug, error, crash, wrong behavior, or asks to debug something.
---

# Debug — Structured Troubleshooting

Systematic debugging workflow for when something is broken.

## Phase 1: Understand the Problem

Ask the user if not already clear from context:

- **Question**: "What's going wrong?"
- **Options**:
  1. **Error/crash** — "I'm getting an error message or exception"
  2. **Wrong behavior** — "It runs but does the wrong thing"
  3. **Performance** — "It's too slow or uses too many resources"
  4. **Intermittent** — "It fails sometimes but not always"

Then gather details:

- **What's the error message or symptom?** (get exact text, not paraphrases)
- **When did it start?** (after a deploy, a dependency update, a code change?)
- **What changed recently?** Check `git log --oneline -20` for recent commits
- **Is it reproducible?** Every time, or intermittent?
- **What's the environment?** Local, staging, production?

## Phase 2: Reproduce

Before diagnosing, confirm the issue is reproducible:

1. **Find the reproduction path** — exact steps, inputs, or conditions
2. **Minimize the case** — strip away unrelated code/data until the issue is isolated
3. **Verify the reproduction** — confirm the issue occurs consistently with the minimal case

If intermittent:

- Check for race conditions (timing-dependent behavior)
- Check for state pollution (previous test/request affecting next)
- Check for external dependencies (network, third-party APIs, database state)
- Try increasing load or running in a loop to make it more frequent

## Phase 3: Isolate

Narrow down where the problem lives:

### Strategy 1: Binary Search (for regressions)

```bash
# Find the commit that introduced the bug
git bisect start
git bisect bad                    # Current commit is broken
git bisect good <known-good-sha> # This commit was working
# Git checks out middle commit — test and mark good/bad
git bisect good  # or  git bisect bad
# Repeat until the breaking commit is found
git bisect reset
```

### Strategy 2: Layer Isolation

Test each layer independently to find where the fault lies:

```text
Request → Router → Middleware → Controller → Service → Database
                                                    ↑ Problem here?

1. Test the database query directly
2. Test the service function with hardcoded input
3. Test the controller with a mock request
4. Test the full request path
```

### Strategy 3: Input/Output Tracing

Add logging at boundaries to trace data flow:

```typescript
// Trace what goes in and comes out at each step
console.log('[Router] params:', params)
console.log('[Service] input:', input)
console.log('[Service] db result:', result)
console.log('[Controller] response:', response)
```

### Strategy 4: Diff Analysis

If it "worked before":

```bash
# What changed in the relevant files?
git log --oneline --all -- path/to/suspect/files
git diff <last-known-good>..HEAD -- path/to/suspect/files
```

## Phase 4: Root Cause

Once the problem location is isolated, identify *why* it fails:

### Common Root Causes

| Category | Symptoms | Check For |
| --- | --- | --- |
| **State** | Works first time, fails after | Stale closures, missing cleanup, shared mutable state |
| **Timing** | Intermittent failures | Race conditions, missing awaits, unhandled promises |
| **Data** | Fails with specific inputs | Null/undefined, type coercion, encoding issues, edge cases |
| **Dependencies** | Fails after update | Breaking API changes, version conflicts, peer dep mismatches |
| **Environment** | Works locally, fails in CI/prod | Missing env vars, different OS/Node version, file paths |
| **Resources** | Degrades over time | Memory leaks, connection pool exhaustion, file handle leaks |

### Framework-Specific Debugging

**React — infinite re-renders:**

```typescript
// Find the cause
useEffect(() => {
  console.log('Effect fired')
  console.trace()  // Shows what triggered the re-render
})

// Common causes:
// - Object/array in dependency array (new reference each render)
// - setState inside useEffect without proper deps
// - Missing dependency causing stale closure
```

**React — stale closures:**

```typescript
// Symptom: callback uses old state value
// Cause: closure captured state at creation time
// Fix: use ref for current value, or functional updater
const countRef = useRef(count)
countRef.current = count
```

**Node.js — unhandled rejections:**

```typescript
// Find unhandled promises
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled rejection at:', promise, 'reason:', reason)
})
```

**Database — slow queries:**

```sql
-- Check query plan
EXPLAIN ANALYZE SELECT ...

-- Common causes: missing index, full table scan, N+1 queries
```

## Phase 5: Fix

1. **Write the fix** — minimum change to address the root cause
2. **Verify the fix** — confirm the reproduction case now passes
3. **Check for collateral** — run the test suite to ensure nothing else broke
4. **Add a test** — write a test that would have caught this bug

### Fix Verification Checklist

- [ ] Reproduction case now passes
- [ ] No other tests broken
- [ ] Edge cases covered (what if the input is null? empty? huge?)
- [ ] No performance regression from the fix
- [ ] Fix addresses root cause, not just the symptom

## Phase 6: Prevent

After fixing, consider whether this class of bug can be prevented:

| Prevention | Example |
| --- | --- |
| **Type narrowing** | `if (!user) throw` before using `user.name` |
| **Validation at boundaries** | Zod schema on API input |
| **Linting rule** | ESLint rule for exhaustive deps, no floating promises |
| **Test** | Unit test for the specific edge case |
| **Runtime guard** | Assertion or invariant check |

## Notes

- Don't guess — verify hypotheses with evidence before changing code
- Don't fix multiple things at once — change one thing, test, then change the next
- If the bug is in a dependency, check the issue tracker before working around it
- Document non-obvious root causes in a code comment at the fix site
- If you can't reproduce it, add logging/monitoring and wait for it to recur
