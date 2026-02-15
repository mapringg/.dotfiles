---
name: commit
description: Generates a concise git commit message from the current diff using conventional commit format. Use when asked to commit changes or create a commit message.
---

# Committing Changes

Generate a concise git commit message from the current diff using conventional commit format.

## Workflow

1. Run `git diff --staged` to get the staged diff
2. If no staged changes, ask the user whether to stage all changes or select specific files
3. Analyze the diff and generate a commit message
4. Present the message to the user for approval
5. Run `git commit -m "<message>"` only after user confirms

## Commit Message Format

```
<type>(<optional scope>): <description>
```

- **Maximum 72 characters** for the first line
- Write in **present tense** ("add feature" not "added feature")
- Be concise and direct
- No period at the end

## Commit Types

| Type | Description |
|------|-------------|
| feat | A new feature |
| fix | A bug fix |
| docs | Documentation only changes |
| style | Changes that do not affect the meaning of the code (white-space, formatting) |
| refactor | A code change that neither fixes a bug nor adds a feature |
| perf | A code change that improves performance |
| test | Adding missing tests or correcting existing tests |
| build | Changes that affect the build system or external dependencies |
| ci | Changes to CI configuration files and scripts |
| chore | Other changes that don't modify src or test files |
| revert | Reverts a previous commit |

## Rules

- Output only the commit message, no explanations
- Choose the type that best describes the overall change
- Scope is optional — use it when the change is clearly scoped to a module/component
- Focus on what the change does, not how
- Exclude unnecessary details like translation or file listings
- If the diff contains multiple unrelated changes, suggest splitting into separate commits
