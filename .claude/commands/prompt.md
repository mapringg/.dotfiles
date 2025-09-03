---
allowed-tools: all
description: Synthesize a complete prompt by combining next.md with your arguments
arguments: task to inject into next.md ($ARGUMENTS)
---

# Prompt Synthesizer

Create a complete prompt by combining:

1. The `next.md` template in `.claude/commands/next.md` (or equivalent path)
2. User task: `$ARGUMENTS`

## Inputs

- `$ARGUMENTS`: Task text to inject into `next.md`.

## Workflow

1. Read the `next.md` command file.
2. Replace the `$ARGUMENTS` placeholder with the actual task.
3. Output the complete, ready-to-use prompt inside a single code block.

## Rules

- Preserve the workflow and requirements from `next.md` verbatim unless tailoring is required by the task.
- If the task mentions specific languages or frameworks, emphasize those relevant sections in the final prompt.
- For complex tasks, retain the "ultrathink" and parallelization guidance.
- For refactoring work, emphasize the "delete old code" and no-compatibility requirements.
- Keep all critical requirements (hooks, linting, testing, validation) intact.

## Output

```
[Complete synthesized prompt ready to copy]
```

Begin synthesis now.
