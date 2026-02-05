---
name: commit
description: Creates git commits matching the repo's existing style. Use when asked to commit, save changes, or make a commit.
---

# Commit Skill

Create well-formatted commits by detecting and following the repository's commit style.

## Workflow

1. Detect style: `git log --oneline -20`
2. Review changes: `git status` and `git diff --staged`
3. Stage files: `git add <files>`
4. Commit using detected pattern (or conventional commits as fallback)

## Quick Reference

| Type | When to use |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation only |
| refactor | Code restructuring |
| test | Adding/fixing tests |
| chore | Maintenance tasks |

## Pattern Detection

| Pattern | Example |
|---------|---------|
| `type: desc` | `feat: add login` |
| `type(scope): desc` | `fix(api): handle null` |
| `type desc` | `add login feature` |
| `Capitalized` | `Add login feature` |

## Examples

```bash
git commit -m "feat: add user authentication"
git commit -m "fix(auth): resolve token expiry"
```
