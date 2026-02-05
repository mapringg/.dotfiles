---
name: tmux
description: Manages background processes via tmux panes or windows. Use when running long-lived processes like dev servers, watchers, or builds.
---

# Tmux Skill

Run and monitor long-running processes without blocking the main session.

## Prerequisites

Check if inside a tmux session before proceeding:

```bash
if [ -z "$TMUX" ]; then echo "Error: Not in a tmux session"; exit 1; fi
```

If not in tmux, stop and inform the user.

## Workflow

1. Ask the user: "pane or window?"
2. Create based on their choice (see commands below)
3. Capture the ID from the output for subsequent commands
4. Use the ID to send commands, read output, or clean up

## Quick Reference

| Action | Command |
|--------|---------|
| Create pane (split right) | `tmux split-window -h -d -c "$(pwd)" -P -F '#{pane_id}'` |
| Create window (end of list) | `tmux new-window -d -c "$(pwd)" -P -F '#{window_id}'` |
| Run command | `tmux send-keys -t "ID" "CMD" C-m` |
| Read output | `tmux capture-pane -p -t "ID"` |
| Full scrollback | `tmux capture-pane -p -S - -t "ID"` |
| Interrupt (Ctrl+C) | `tmux send-keys -t "ID" C-c` |
| Kill pane | `tmux kill-pane -t "ID"` |
| Kill window | `tmux kill-window -t "ID"` |

## Examples

```bash
# Create pane, capture ID, run command
PANE_ID=$(tmux split-window -h -d -c "$(pwd)" -P -F '#{pane_id}')
tmux send-keys -t "$PANE_ID" "npm start" C-m

# Create window, capture ID, run command
WINDOW_ID=$(tmux new-window -d -c "$(pwd)" -P -F '#{window_id}')
tmux send-keys -t "$WINDOW_ID" "npm run build" C-m

# Read output from a pane
tmux capture-pane -p -S - -t "$PANE_ID"
```
