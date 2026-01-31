---
name: tmux
description: Manage background processes (servers, builds) via tmux windows.
---

# Tmux Skill

Run and monitor long-running processes without blocking the main session.

## Quick Reference

| Action | Command |
|--------|---------|
| Create window | `tmux new-window -n "ID" -d` |
| Run command | `tmux send-keys -t "ID" "CMD" C-m` |
| Read output | `tmux capture-pane -p -t "ID"` |
| Full scrollback | `tmux capture-pane -p -S - -t "ID"` |
| Interrupt (Ctrl+C) | `tmux send-keys -t "ID" C-c` |
| Kill window | `tmux kill-window -t "ID"` |

## Workflow

1. Create a detached window: `tmux new-window -n "server" -d`
2. Send command to it: `tmux send-keys -t "server" "npm start" C-m`
3. Check output anytime: `tmux capture-pane -p -t "server"`
4. Clean up when done: `tmux kill-window -t "server"`

## Examples

```bash
# One-liner: create window and start process
tmux new-window -n "server" -d ';' send-keys -t "server" "npm start" C-m

# Read full output history
tmux capture-pane -p -S - -t "server"
```
