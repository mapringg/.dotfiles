# Counselors CLI Reference

## Discovery

```bash
counselors ls           # list configured agents (IDs + binaries)
counselors groups ls    # list configured groups (predefined tool sets)
```

Tool selection flags (apply to both `run` and `loop`):

- `--tools claude,codex,gemini` — explicit tool list
- `--group smart` — use a configured group
- `--group smart --tools codex` — group plus additional tools

## Prompt File Creation

Both `run` and `loop + file` modes require a prompt file. Create one via:

```bash
cat <<'PROMPT' | counselors mkdir --json
[assembled prompt content]
PROMPT
```

Parse the JSON output to read `promptFilePath` and `outputDir`.

## Run Mode (single-shot)

```bash
counselors run -f <promptFilePath> --tools [comma-separated-tool-ids] --json
```

## Loop Mode (iterative)

### Loop + file (custom prompt)

```bash
counselors loop -f <promptFilePath> --tools [comma-separated-tool-ids] --json
```

### Loop + inline (auto-enhanced)

```bash
counselors loop "find race conditions in the worker pool" --tools [comma-separated-tool-ids] --json
```

Add `--no-inline-enhancement` to skip discovery/prompt-writing and send the raw prompt as-is.

### Loop + preset

```bash
counselors loop --preset <preset-name> "<focus area>" --tools [comma-separated-tool-ids] --json
```

List available presets: `counselors loop --list-presets`

### Loop Flags

| Flag                              | Description                                                  |
| --------------------------------- | ------------------------------------------------------------ |
| `--rounds <N>`                    | Number of rounds (default: 3)                                |
| `--duration <time>`               | Max wall time (`30m`, `1h`); unlimited rounds when set alone |
| `--convergence-threshold <ratio>` | Early stop ratio (default: 0.3)                              |
| `--discovery-tool <id>`           | Agent for prep phases (default: first tool)                  |
| `--no-inline-enhancement`         | Skip discovery/prompt-writing for inline prompts             |

### Loop Behavior

In rounds 2+, counselors augments the prompt with `@file` references to prior round outputs. Agents are instructed to not repeat findings, challenge prior claims, follow adjacent code paths discovered in earlier rounds, and label overlaps as confirmed/refined/invalidated/duplicate.

## Output Structure

### Run output

```text
{outputDir}/
├── prompt.md
└── {tool-id}.md
```

Read each `{tool-id}.md` for the agent's response.

### Loop output

```text
{outputDir}/
├── round-1/
│   ├── prompt.md
│   ├── {tool-id}.md
│   └── round-notes.md
├── round-2/
│   └── ...
├── final-notes.md
└── run.json
```

The manifest's `rounds` array contains per-round tool reports. `totalRounds` and `durationMs` are top-level fields.

**Reading order**: start with `final-notes.md` for a cross-round summary, then `round-notes.md` per round, then drill into per-agent `{tool-id}.md` files as needed.

## Timing

Sessions commonly take **10–20+ minutes**. Counselors emits periodic heartbeat lines to stdout and prints each child PID alongside the agent name. Verify with `ps -p <PID>`.
