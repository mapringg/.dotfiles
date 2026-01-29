---
name: committing
description: "Creates git commits following conventional commit patterns. Use when asked to commit, make a commit, or save changes."
---

# Committing Skill

Creates well-formatted git commits by detecting the repository's existing commit style.

## Workflow

1. **Analyze repo pattern first**: Run `git log --oneline -20` to detect the commit style
2. **Identify the pattern**:
   - Look for consistent prefixes (feat:, fix:, add, update, etc.)
   - Check for colons, scopes, capitalization
   - Note any consistent formatting
3. **Follow detected pattern** if one exists
4. **Fall back to conventional commits** if no clear pattern

## Pattern Detection Examples

| Detected Pattern | Example Commits |
|-----------------|-----------------|
| `type: desc` | `feat: add login`, `fix: resolve crash` |
| `type(scope): desc` | `feat(auth): add JWT`, `fix(api): handle null` |
| `type desc` (no colon) | `add login feature`, `fix crash on startup` |
| `[type] desc` | `[feat] add login`, `[fix] resolve crash` |
| Capitalized | `Add login feature`, `Fix crash` |

## Default: Conventional Commits

When no repo pattern exists, use standard conventional commits:

```
<type>(<optional-scope>): <description>
```

### Types

| Type     | When to use                              |
|----------|------------------------------------------|
| feat     | New feature                              |
| fix      | Bug fix                                  |
| docs     | Documentation only                       |
| style    | Formatting, no code change               |
| refactor | Code restructuring, no behavior change   |
| perf     | Performance improvement                  |
| test     | Adding or fixing tests                   |
| build    | Build system or dependencies             |
| ci       | CI configuration                         |
| chore    | Maintenance tasks                        |
| revert   | Reverting a previous commit              |

### Default Examples

```bash
git commit -m "feat: add user authentication"
git commit -m "fix: resolve null pointer in login"
git commit -m "feat(auth): implement JWT tokens"
git commit -m "docs: update API documentation"
```

## Commit Steps

1. Run `git log --oneline -20` to detect pattern
2. Run `git status` to see changes
3. Run `git diff --staged` (or `git diff`) to understand changes
4. Stage files if needed: `git add <files>`
5. Commit using detected pattern (or conventional commits as fallback)

## Multi-line Commits

For complex changes:

```bash
git commit -m "feat: add user authentication" -m "- implement JWT tokens
- add login/logout endpoints
- create user session middleware"
```
