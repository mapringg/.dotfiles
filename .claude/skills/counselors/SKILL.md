---
name: counselors
description: Get parallel second opinions from multiple AI coding agents. Use when the user wants independent reviews, architecture feedback, or a sanity check from other AI models.
---

# Counselors

Fan out a prompt to multiple AI coding agents in parallel and synthesize their responses. Use `run` for single-shot review, or `loop` for iterative multi-round analysis.

> **⏱ Long-running.** Total wall time is commonly **10–20+ minutes**. Consider running dispatch in the background and checking results periodically.

## Workflow

### 1. Context Gathering

Parse the user's request and identify relevant context:

1. **Files mentioned**: Use Glob/Grep to find files referenced by name, class, function, or keyword
2. **Recent changes**: Run `git diff HEAD` and `git diff --staged`
3. **Related code**: Search for key terms to identify the most relevant files (up to 5)

Subagents have filesystem and git access — reference files with `@path/to/file` instead of inlining contents.

### 2. Mode Selection

1. **Default to `run`** for a quick second-opinion pass
2. **Use `loop`** for deeper iterative analysis or multi-round convergence
3. If using `loop`, choose: **preset** (`--preset`), **custom** (`-f`), or **inline** (auto-enhanced)

If the user asks for a preset: `counselors loop --list-presets`

### 3. Agent Selection

1. Discover available agents and groups:

   ```bash
   counselors ls
   counselors groups ls
   ```

2. **Print the full output**, then ask the user which agents to use
3. **Confirm the selection** before proceeding:
   > Dispatching to: **claude-opus**, **codex-5.3-high**, **gemini-pro**

### 4. Prompt Assembly

For `run` and custom `loop` modes, assemble a review prompt. Skip for preset and inline loop modes.

Subagents can read files themselves — use `@file` references, not inlined code. Only inline small critical snippets (e.g., a specific error message).

```markdown
# Review Request

## Question
[User's original prompt/question]

## Context
### Files to Review
[List @path/to/file references]

### Recent Changes
[Brief description; tell agents to run `git diff HEAD` themselves]

## Instructions
You are providing an independent review. Be critical and thorough.
- Read the referenced files to understand the full context
- Identify risks, tradeoffs, and blind spots
- Suggest alternatives if you see better approaches
- Be direct and opinionated — don't hedge
```

### 5. Dispatch

See `reference/cli.md` for full command syntax. Key patterns:

- **Run**: `counselors mkdir --json` → `counselors run -f <promptFilePath> --tools ... --json`
- **Loop (custom)**: `counselors mkdir --json` → `counselors loop -f <promptFilePath> --tools ... --json`
- **Loop (inline)**: `counselors loop "prompt" --tools ... --json`
- **Loop (preset)**: `counselors loop --preset <name> "focus" --tools ... --json`

### 6. Synthesize and Present

Read each agent's response from the output manifest, then present:

```markdown
## Counselors Review

**Agents consulted:** [list]
**Consensus:** [key takeaways]
**Disagreements:** [where they differ]
**Key Risks:** [concerns flagged]
**Blind Spots:** [things no agent addressed]
**Recommendation:** [synthesized recommendation]
```

After presenting, ask the user what they'd like to address. Offer the top 2–3 actionable items.

## Error Handling

- **Not installed**: `npm install -g counselors`
- **No tools configured**: `counselors init` or `counselors tools add <tool>`
- **Agent fails**: Note in synthesis, continue with other results
- **All agents fail**: Check stderr files, suggest `counselors doctor`
