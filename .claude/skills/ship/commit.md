# Committing Changes

Generate a concise git commit message from the current diff using conventional commit format.

## Workflow

1. Run `git diff --staged` to get the staged diff
2. If no staged changes, run `git status` to show the user what's available, then ask whether to stage all changes or select specific files
3. Analyze the diff and generate a commit message
4. Present the message to the user for approval — explain your reasoning briefly (e.g., why you chose the type/scope)
5. Run `git commit` only after user confirms, using a HEREDOC for the message

## Commit Message Format

```
<type>(<optional scope>): <description>

<optional body>
```

### Subject Line

- **Maximum 72 characters**
- Write in **present tense** ("add feature" not "added feature")
- Be concise and direct
- No period at the end

### Body (optional)

- Include a body when the diff is non-trivial or touches multiple areas
- Separate from the subject with a blank line
- Wrap lines at 72 characters
- Explain **what** changed and **why**, not how
- Use bullet points for multiple distinct changes

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

- Choose the type that best describes the overall change
- Scope is optional — use it when the change is clearly scoped to a module/component
- Focus on what the change does, not how
- Exclude unnecessary details like file listings or translation strings
- If the diff contains multiple unrelated changes, suggest splitting into separate commits
