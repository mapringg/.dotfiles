---
allowed-tools: all
description: Verify code quality and fix all issues
arguments: none
---

# Code Quality Check

Purpose: Run all quality gates, fix every failure, and verify a clean state. Do not just report problems—remediate them.

## Inputs

- `$ARGUMENTS`: Not used.

## Workflow

1. Discover checks
   - Prefer `pnpm`; fallback to `yarn` or `npm` if needed.
   - If a script does not exist, look for common alternatives and framework-specific commands.
2. Run all checks
   - Lint: `pnpm run lint` (or `yarn lint` / `npm run lint`)
   - Test: `pnpm run test` (consider `--watch=false` for CI-like runs)
   - Typecheck: `pnpm run typecheck` if present (e.g., `tsc -p . --noEmit`)
   - Build: `pnpm run build`
   - Format: `pnpm run format` or `pnpm run fmt` if configured
   - Security: `pnpm audit` or `npm audit` (if applicable)
3. Fix issues
   - Address lint, type, test, and build failures.
   - Update code, configs, or tests as required—no TODOs left behind.
4. Re-run checks until all pass
   - Iterate until zero errors and zero warnings (where warnings are treated as failures by config or policy).

## Rules

- Monorepos: Detect package-level scripts; run at root and per-package as appropriate.
- Caching: Clear caches if stale results are suspected (e.g., `pnpm store prune`, framework caches).
- Safety: Avoid disabling rules or tests unless there is a well-documented, justified exception.

## Success Criteria

- All configured quality commands pass.
- No linter or typechecker warnings remain (strict mode).
- Tests are green and reproducible locally.
