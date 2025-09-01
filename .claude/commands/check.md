---
allowed-tools: all
description: Verify code quality and fix all issues
---

# Code Quality Check

Fix all issues found during quality verification. Do not just report problems.

## Core Workflow

1. **Identify** - Run all validation commands
2. **Fix** - Address every issue found
3. **Verify** - Re-run until all checks pass

## Validation Commands

Find and run all applicable commands:

- **Lint**: `npm run lint`
- **Test**: `npm test`
- **Build**: `npm run build`
- **Format**: `prettier`
- **Security**: `npm audit`

## Parallel Fixing Strategy

When multiple issues exist, spawn agents to fix in parallel:

```
Agent 1: Fix linting issues in module A
Agent 2: Fix test failures
Agent 3: Fix type errors
```

## Success Criteria

All validation commands pass with zero warnings or errors.
