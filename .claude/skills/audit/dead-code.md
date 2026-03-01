# Dead Code Audit

Detect unused exports, unreachable code, orphaned files, and stale feature flags.

## The Core Problem

Dead code degrades comprehensibility and introduces maintenance risk. Research (Romano et al., IEEE TSE 2020) found dead code persists for many commits before removal and is "rarely revived." It confuses developers, increases bundle size, and creates false dependencies.

## What This Command Detects

| Pattern | Confidence | Description |
|---------|------------|-------------|
| **Unreachable Code** | 100% | Code after return/throw/break |
| **Unused Imports** | 90% | Imported but never referenced |
| **Orphaned Files** | 85% | Files unreachable from entry points |
| **Unused Exports** | 60% | Exported but never imported elsewhere |
| **Commented-out Code** | 70% | Old code left in comments |
| **Stale Feature Flags** | 80% | Flags at 100%/0% for extended periods |

## Phase 1: Discover the Codebase

1. **Identify entry points**:
   - Package.json main/exports/bin
   - Index files (index.ts, index.js, **init**.py)
   - Framework entry points (app.ts, main.py, App.vue)
   - Route definitions
   - Test entry points

2. **Build dependency graph**:
   - Parse all imports/requires
   - Map exports to their consumers
   - Identify re-exports

3. **Identify framework patterns**:
   - Route handlers (may look unused but are dynamically invoked)
   - Lifecycle hooks
   - Decorators and annotations
   - Plugin architectures

## Phase 2: Parallel Audit (Using Subagents)

**Launch 5 subagents in parallel** using `Agent` with `subagent_type=Explore`. See [dead-code-subagents.md](dead-code-subagents.md) for detailed prompts.

| Subagent | Focus | Confidence |
|----------|-------|------------|
| 1 | Unreachable code (after return/throw/break, always-true/false conditions, duplicate branches) | 100% |
| 2 | Unused imports & exports | 60-90% |
| 3 | Orphaned files (unreachable from entry points) | 85% |
| 4 | Commented-out code (vs documentation comments) | 70% |
| 5 | Stale feature flags & dead conditionals | 80% |

Pass tech stack and entry points from Phase 1 to each subagent.

## Phase 3: Confidence-Based Actions

| Confidence | Action | Automation |
|------------|--------|------------|
| **100%** | Auto-remove safe | Can delete without review |
| **90%** | Brief review | Quick check, usually safe |
| **85%** | Check for dynamic usage | Verify no runtime loading |
| **70%** | Manual review | May be intentional |
| **60%** | Flag for discussion | Could break things |

## Phase 4: Present Findings

```markdown
## Dead Code Audit Results

### Summary
- X unreachable code blocks (100% safe to delete)
- X unused imports (90% confidence)
- X orphaned files (85% confidence)
- X unused exports (60% confidence)
- X commented code blocks (70% confidence)
- X stale feature flags (80% confidence)

### Estimated Impact
- Lines removable: ~X
- Files deletable: X
- Bundle size reduction: ~X KB (estimate)

### 100% Confidence - Auto-remove Safe
| Location | Type | Code |
|----------|------|------|
| file:line | Unreachable after return | `console.log(...)` |

### 90% Confidence - Brief Review
| Location | Type | Symbol |
|----------|------|--------|
| file:line | Unused import | `debounce` |

### 85% Confidence - Check Dynamic Usage
| File | Reason | Imported By |
|------|--------|-------------|
| utils/old.ts | No static imports | None |

### 60-70% Confidence - Manual Review Required
| Location | Type | Notes |
|----------|------|-------|
| file:line | Unused export | May be public API |
```

## Phase 5: Fix Options

1. **Auto-remove 100% confidence**:
   - Delete unreachable code
   - Run tests to verify

2. **Remove with review**:
   - Delete unused imports (90%)
   - Delete orphaned files (85%)
   - Run full test suite

3. **Flag for deprecation**:
   - Add @deprecated to unused exports
   - Set removal timeline

4. **Generate cleanup PR**:
   - Batch safe deletions
   - Separate risky deletions

5. **Report only**:
   - Export findings for team review

## Framework-Specific False Positive Rules

### React/Next.js

- Don't flag: Components (may be dynamically routed)
- Don't flag: Pages in /pages or /app directory
- Don't flag: API routes

### Express/Fastify

- Don't flag: Route handlers
- Don't flag: Middleware functions
- Check: Plugin/extension files

### Vue/Nuxt

- Don't flag: Components (may be auto-imported)
- Don't flag: Composables in /composables
- Don't flag: Pages in /pages

### Python/Django/Flask

- Don't flag: Views (URL routed)
- Don't flag: Management commands
- Don't flag: Migrations
- Check: Celery tasks

### Laravel/PHP

- Don't flag: Controllers (routed)
- Don't flag: Jobs, Events, Listeners
- Don't flag: Blade components
- Check: Service providers

## Notes

- Run tests after any deletion
- Commented code is recoverable via git history
- Some "dead" code is intentional (future use, A/B tests)
- Dynamic imports make static analysis incomplete
- Consider running in CI to catch new dead code
