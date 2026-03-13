---
name: commit
description: Generates conventional commit messages for staged changes. Use when committing code, writing commit messages, or asked to commit.
---

# Commit

Generate and apply commit messages following the [Conventional Commits](https://www.conventionalcommits.org) specification.

## Goal

Produce a commit message that accurately reflects the **staged changes only**.

Prefer a **single-line subject** unless additional explanation is necessary.

## Format

```text
type: description
type(scope): description
type!: description
type(scope)!: description
````

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
| revert   | Reverting a previous commit                             |

## Rules

1. Use **imperative mood**

    * ✅ `add auth middleware`
    * ❌ `added auth middleware`

2. Keep the description **lowercase**

    * ✅ `handle expired refresh tokens`
    * ❌ `Handle Expired Refresh Tokens`

3. Do **not** end the description with a period

    * ✅ `fix(api): handle null response`
    * ❌ `fix(api): handle null response.`

4. The **type must match the dominant purpose** of the staged change

5. Do **not repeat the type as a verb** in the description

    * ✅ `fix: resolve null pointer in auth handler`
    * ❌ `fix: fix null pointer in auth handler`

6. Keep the description under ~72 characters when possible

7. Do **not** describe the change using file names only
    * ❌ `fix: update auth.js`
    * ❌ `refactor: modify userService.ts`
    * ✅ `fix(auth): validate token expiration`
    * ✅ `refactor(users): extract shared service logic`

8. Use a **scope** only when the affected area is clear and specific

    * ✅ `fix(auth): handle expired refresh tokens`
    * ✅ `chore(ci): update test matrix`
    * ✅ `feat: add retry logic for uploads`
    * If the scope is unclear, broad, or spans multiple areas, **omit it**

9. Prefer **subject-only commits**

   * Add a body only when the change needs extra context

10. Mark **breaking changes** with `!`

    * ✅ `feat(api)!: remove v1 endpoints`

11. Base the message on **staged changes only**

    * Ignore unstaged and untracked changes unless the user asks otherwise

12. If multiple unrelated changes are staged, recommend splitting them into separate commits

    * If splitting is not possible, describe the **most significant** change

## Type Selection Guide

Choose the type using this priority:

* **feat** → introduces new user-facing or developer-facing behavior
* **fix** → corrects incorrect behavior or a defect
* **refactor** → changes structure without changing behavior
* **perf** → improves performance without changing intended behavior
* **docs** → documentation only
* **test** → tests only
* **style** → formatting or cosmetic-only changes
* **ci** → CI/CD pipeline or workflow changes
* **build** → build tooling, packaging, dependency/build system changes
* **chore** → maintenance or repo tasks not better described by another type
* **revert** → reverses a previous commit

When in doubt, choose the **smallest accurate type** rather than overstating the change.

## Workflow

1. Run `git diff --staged` to inspect what is being committed
2. If nothing is staged, tell the user that nothing is staged and ask what should be staged
3. Summarize the staged changes in one sentence
4. Determine the dominant purpose of the change
5. Identify a scope only if one area is clearly targeted
6. Write a concise conventional commit subject
7. Reject and rewrite descriptions that are vague, generic, or could apply to many unrelated changes
8. Add a body only if needed for:
   * breaking changes
   * migrations
   * behavior changes that need explanation
   * non-obvious implementation context
9. Commit using the command line:
   * For subject-only: `git commit -m "type(scope): description"`
   * With a body: `git commit -m "type(scope): description" -m "body content here"`

## Body Guidelines

Use a body when necessary. Keep it brief and explanatory.

Example:

```text
feat(auth)!: replace session tokens with jwt

remove server-side session storage and issue signed jwt tokens instead
```

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
test(auth): add integration tests for oauth flow
build: update vite build configuration
revert: undo broken cache invalidation change
feat(api)!: remove v1 endpoints
```
