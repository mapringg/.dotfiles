---
name: counselors
description: Get parallel second opinions from multiple AI coding agents. Use when the user wants independent reviews, architecture feedback, or a sanity check from other AI models.
---

# Counselors

Fan out a prompt to multiple AI coding agents in parallel and synthesize their responses. Use `run` for single-shot review, or `loop` for iterative multi-round analysis.

> **⏱ Long-running.** Total wall time is commonly **10–20+ minutes**. Consider running dispatch in the background and checking results periodically.

## Dispatch Modes

| Mode | Prompt assembly? | Command pattern |
| --- | --- | --- |
| **Run** | Yes | `counselors run -f <promptFile> --tools ... --json` |
| **Loop + file** | Yes | `counselors loop -f <promptFile> --tools ... --json` |
| **Loop + inline** | No (auto-enhanced) | `counselors loop "prompt" --tools ... --json` |
| **Loop + preset** | No (preset-driven) | `counselors loop --preset <name> "focus" --tools ... --json` |

## Workflow

### 1. Context Gathering

Parse the user's request and identify relevant context:

1. **Files mentioned**: Use Glob/Grep to find files referenced by name, class, function, or keyword
2. **Recent changes**: Run `git diff HEAD` and `git diff --staged`
3. **Related code**: Search for key terms to identify the most relevant files (up to 5)

Subagents have filesystem and git access — reference files with `@path/to/file` instead of inlining contents.

**If no arguments provided**, ask the user what they want reviewed.

### 2. Mode Selection

1. **Default to `run`** for a quick second-opinion pass
2. **Use `loop`** for deeper iterative analysis or multi-round convergence
3. If using `loop`, choose the sub-mode:
   - **Preset** (`--preset`): use for domain workflows (bug, security, performance, etc.). Run `counselors loop --list-presets` to list options
   - **Custom file** (`-f`): you write a full prompt file, same as `run`
   - **Inline** (auto-enhanced): pass a short prompt string; counselors runs discovery + prompt-writing phases automatically

### 3. Agent Selection

1. Discover available agents and groups:

   ```bash
   counselors ls
   counselors groups ls
   ```

2. **Print the full output** of both commands, then ask the user which agents to use
3. Wait for the user's selection
4. **Confirm the exact selection before dispatching** — do not proceed without explicit confirmation:
   > Dispatching to: **claude-opus**, **codex-5.3-high**, **gemini-pro** — look good?

If the user names a group, expand it to the underlying tool IDs and confirm that expanded list.

### 4. Prompt Assembly

**Skip this step for loop + inline and loop + preset modes** — counselors handles prompt generation automatically.

For `run` and `loop + file` modes, assemble a review prompt. Counselors automatically appends execution boilerplate (focus on source dirs, skip vendor/binary files, provide file paths for findings), so you do not need to include those instructions.

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
- Analyze the question in the context provided
- Identify risks, tradeoffs, and blind spots
- Suggest alternatives if you see better approaches
- Be direct and opinionated — don't hedge
- Structure your response with clear headings
```

### 5. Dispatch

See `reference/cli.md` for full command syntax and flags.

All modes that use a prompt file (`run` and `loop + file`) require creating the file first via `counselors mkdir --json`, then dispatching with `-f <promptFilePath>`.

### 6. Read Results

1. Parse the `--json` output from dispatch — the manifest contains status, duration, word count, and output file paths for each agent
2. Read each agent's response from the `outputFile` path in the manifest
3. Check `stderrFile` paths for any agent that failed or returned empty output — skip empty or error-only reports
4. Reading order:
   - **Run mode**: read each `{tool-id}.md` directly
   - **Loop mode**: start with `final-notes.md` for a cross-round summary, then `round-notes.md` per round, then drill into per-agent outputs as needed

### 7. Synthesize and Present

Combine all agent responses into a synthesis:

```markdown
## Counselors Review

**Agents consulted:** [list]
**Consensus:** [key takeaways]
**Disagreements:** [where they differ]
**Key Risks:** [concerns flagged]
**Blind Spots:** [things no agent addressed]
**Recommendation:** [synthesized recommendation]

---
Reports saved to: [output directory from manifest]
```

After presenting, ask the user what they'd like to address. Offer the top 2–3 actionable items. If the user wants to act on findings, plan the implementation before making changes.

## Error Handling

- **Not installed**: `npm install -g counselors`
- **No tools configured**: `counselors init` or `counselors tools add <tool>`
- **Invalid tool/group/preset**: report the error and ask the user to choose again
- **Agent fails**: note in synthesis, continue with other results
- **All agents fail**: check stderr files, suggest `counselors doctor`
- **JSON parse failure**: re-run the command and check for stderr output
