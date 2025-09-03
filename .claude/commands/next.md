---
allowed-tools: all
description: Execute production-quality implementation
arguments: task to implement ($ARGUMENTS)
---

# Production Implementation

Implement: `$ARGUMENTS`

## Inputs

- `$ARGUMENTS`: Task description and scope to implement.

## Workflow

1. Research
   - Explore the codebase, dependencies, and constraints.
   - Identify affected modules and integration points.
2. Plan
   - Propose a concise approach and receive confirmation if needed.
   - Define milestones and validation steps.
3. Implement
   - Build iteratively with continuous validation and small commits.
   - For independent parts, parallelize effort where possible.
   - For complex architecture, perform deep design thinking ("ultrathink") before coding.
4. Validate
   - Run lint, typecheck, tests, and build frequently.
   - Verify behavior in realistic scenarios.
5. Wrap up
   - Remove dead code and TODOs; finalize docs and tests.

## Rules

### Code Evolution

- Replace old code entirely when refactoring.
- Avoid versioned names (e.g., `processV2`, `handleNew`).
- No temporary compatibility layers or migration scaffolding.
- Implement the final solution directly for this branch.

### Quality Gates

- Run linters after every few file edits.
- Keep the working tree green; fix warnings immediately.
- Run the full test suite before declaring completion.

### General Requirements

- Follow existing codebase patterns and conventions.
- Use strict, language-appropriate linters and formatters.
- Write focused tests for business logic and critical paths.
- Ensure end-to-end functionality and error handling.

## Success Criteria

- All linters and type checks pass with zero warnings.
- All tests pass (including race checks where applicable).
- The feature works in realistic scenarios and edge cases.
- No TODOs, temporary code, or dead paths remain.
