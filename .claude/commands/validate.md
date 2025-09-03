---
allowed-tools: all
description: Deep validation of completed implementation
arguments: none
---

# Implementation Validation

Perform deep, structured validation of the implementation just completed.

## Inputs

- `$ARGUMENTS`: Not used.

## Workflow

1. Begin with: "Let me ultrathink about this implementation and examine the code closely."
2. Read the relevant code, tests, and configuration.
3. Execute the checks below and note findings and severities.

## Rules

- Be direct and honest; cite specific files or functions when possible.
- Treat warnings in linters/type checks as failures unless documented.
- Prefer minimal, targeted fixes over large refactors unless required.

## Success Criteria

### Task Completeness

- All requirements fully implemented.
- Edge cases handled and documented.
- No missing or partial functionality.

### Code Quality

- Idiomatic for the language and framework.
- Solid error handling and resource management.
- Functions and modules sized appropriately and cohesive.

### Architecture Integrity

- No duplicate code paths or reimplemented wheels.
- Consistent with existing patterns and boundaries.
- No over-engineering or unnecessary abstractions.

### Hidden Issues

- Potential race conditions or concurrency pitfalls.
- Security vulnerabilities or unsafe defaults.
- Performance bottlenecks or N+1 patterns.
- Missing or brittle test coverage in critical paths.

## Output

- ✅ Done Well: Specific achievements with brief examples.
- ⚠️ Issues Found: Problems with severity and why they matter.
- Fix Plan: Concrete steps (or patches) to resolve each issue.
- 📊 Verdict: Is the implementation truly complete and production-ready?

Offer to fix any identified issues immediately.
