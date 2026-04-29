#!/bin/bash
set -eo pipefail

commits=$(git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found")
issues=$(find .scratch -name '*.md' -not -path '*/done/*' -exec cat {} + 2>/dev/null)
[ -z "$issues" ] && issues="No issues found"
prompt=$(cat $HOME/.dotfiles/ralph/prompt.md)

claude --dangerously-skip-permissions \
  "Previous commits: $commits Issues: $issues $prompt"
