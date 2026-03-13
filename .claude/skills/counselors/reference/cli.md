# Counselors CLI Reference

## Run Mode (single-shot)

Create output directory and prompt file, then dispatch:

```bash
cat <<'PROMPT' | counselors mkdir --json
[assembled prompt content]
PROMPT
```

Parse the JSON output and read `promptFilePath`, then dispatch:

```bash
counselors run -f <promptFilePath> --tools [comma-separated-tool-ids] --json
```

Tool selection examples:

- `--tools claude,codex,gemini`
- `--group smart` (uses the configured group)
- `--group smart --tools codex` (group plus explicit tools)

## Loop Mode (iterative)

### Custom prompt file

```bash
counselors loop -f <promptFilePath> --tools [comma-separated-tool-ids] --json
```

### Inline prompt (auto-enhanced)

```bash
counselors loop "find race conditions in the worker pool" --tools [comma-separated-tool-ids] --json
```

Add `--no-inline-enhancement` to skip discovery/prompt-writing and send the raw prompt as-is.

### Preset

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

In rounds 2+, counselors augments the prompt with `@file` references to prior round outputs. Agents are instructed to not repeat findings, challenge prior claims, and label overlaps as confirmed/refined/invalidated/duplicate.

## Output Structure

### Run output

```text
{outputDir}/
├── prompt.md
└── {tool-id}.md
```

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

Start with `final-notes.md` for a high-level summary, then drill into individual round outputs as needed.

## Timing

Sessions commonly take **10–20+ minutes**. Counselors prints each child PID alongside the agent name. Verify with `ps -p <PID>`.
