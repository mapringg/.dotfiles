---
name: commit
description: Generates conventional commit messages for staged changes. Use when committing code, writing commit messages, or asked to commit.
---

# Commit

Generate and apply commit messages following the [Conventional Commits](https://www.conventionalcommits.org) specification.

## Format

```text
type(scope): description

type(scope)!: description   # breaking change
```

- **type**: Required. One of the types below.
- **scope**: Optional. The module, component, or area affected.
- **description**: Required. Imperative mood, lowercase, no period.
- **`!`**: Append after the type/scope to flag a breaking change.

## Types

| Type     | When to use                                             |
| -------- | ------------------------------------------------------- |
| feat     | A new feature or capability                             |
| fix      | A bug fix                                               |
| refactor | Code change that neither fixes a bug nor adds a feature |
| style    | Formatting, whitespace, or cosmetic changes             |
| chore    | Maintenance, dependencies, or tooling                   |
| docs     | Documentation only changes                              |
| perf     | A performance improvement                               |
| test     | Adding or correcting tests                              |
| ci       | CI/CD configuration changes                             |
| build    | Build system or external dependency changes             |

## Rules

1. Use **imperative mood**: "add auth middleware" not "added auth middleware"
2. **Lowercase** the description: "add retry logic" not "Add Retry Logic"
3. **No period** at the end of the description
4. The **type must match the action** — don't use `feat` for a bug fix or `fix` for a refactor
5. **Do not repeat the type as a verb** in the description:
   - ✅ `fix: resolve null pointer in auth handler`
   - ❌ ~~`fix: fix null pointer in auth handler`~~
6. **Prefer subject-only commits** — skip the body unless the change needs explanation
7. Use a **scope** when the change is clearly scoped to one area
8. Mark **breaking changes** with `!` after the type/scope: `feat(api)!: remove v1 endpoints`

## Workflow

1. Run `git diff --staged` to see what is being committed
2. If nothing is staged, ask the user what to stage
3. Determine the correct type based on the nature of the change
4. Identify a scope if the change targets a specific module or area
5. Write a concise imperative description
6. Commit with `git commit -m "type(scope): description"`

## Examples

```text
feat: add user authentication flow
feat(api): add rate limiting to public endpoints
fix: resolve race condition in worker pool
fix(auth): handle expired refresh tokens
refactor: extract validation into shared module
refactor(db): simplify query builder interface
style: format markdown tables in config files
chore: update dependencies to latest versions
chore(ci): add node 22 to test matrix
docs: add API authentication guide
perf(db): add index for user lookup queries
test(auth): add integration tests for OAuth flow
feat(api)!: remove v1 endpoints
```
