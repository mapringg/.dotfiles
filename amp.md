# Amp Best Practices

Based on the Amp manual, here are the key best practices:

## Prompting

- **Be explicit** - use "do X" instead of "can you do X?"
- **Keep prompts short and focused** - break large tasks into smaller sub-tasks
- **Don't make the model guess** - include specific files, commands, or context you know
- **State clearly if you want planning only**: "Only plan how to implement this. Do NOT write any code."

## Project Setup

- **Use `AGENTS.md` files** to guide Amp on build/test commands, architecture, and conventions
- **Place them strategically** in project root, parent directories, and subtrees as needed
- **Include @-mentions** of relevant documentation files in `AGENTS.md`

## Context Management

- **Start fresh threads** when accumulated noise/errors clutter context
- **Use "Compact Thread"** when approaching context limits
- **Put effort into your first prompt** - it sets direction for the entire conversation
- **Tell the agent how to review its work** (what commands to run, URLs to check)

## Tool Usage

- **Be selective with MCP servers** - too many tools reduce performance
- **Disable unused MCP tools** to improve model performance
- **Use permissions** to control which tools can run automatically vs requiring approval

## Workflow

- **Mention specific files with @** to speed up responses
- **Queue follow-up messages** with Cmd/Ctrl+Shift+Enter
- **Use subagents** for complex, independent tasks that can run in parallel
- **Ask for Oracle** when you need complex reasoning or analysis

## Code Quality

- **Run lint/typecheck commands** after making changes
- **Use custom slash commands** for reusable prompts
- **Follow existing code conventions** and check for available libraries first
- **Never commit secrets** or expose sensitive information

## Key Principles

The manual emphasizes being explicit, focused, and systematic in your approach while leveraging Amp's tools effectively.