#!/bin/bash
set -eo pipefail

if [ -z "$1" ]; then
  echo "Usage: $0 <iterations>"
  exit 1
fi

ITERATIONS=$1

stream_text='select(.type == "assistant").message.content[]? | select(.type == "text").text // empty | gsub("\n"; "\r\n") | . + "\r\n\n"'
final_result='select(.type == "result").result // empty'

tmpfile=""

cleanup() {
  [[ -n "$tmpfile" ]] && rm -f "$tmpfile"
}
trap cleanup EXIT

run_claude() {
  local prompt_text=$1
  tmpfile=$(mktemp)

  claude --dangerously-skip-permissions \
    --verbose \
    --print \
    --output-format stream-json \
    "$prompt_text" \
  | grep --line-buffered '^{' \
  | tee "$tmpfile" \
  | jq --unbuffered -rj "$stream_text"
}

build_implement_prompt() {
  local commits=$(git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found")
  local issues=$(find .scratch -name '*.md' -not -path '*/done/*' -exec cat {} + 2>/dev/null)
  [ -z "$issues" ] && issues="No issues found"
  local body=$(cat "$HOME/.dotfiles/ralph/implement-prompt.md")

  cat <<EOF
<recent-commits>
$commits
</recent-commits>

<issues>
$issues
</issues>

$body
EOF
}

build_review_prompt() {
  local pre_sha=$1
  local commits=$(git log -n 10 --format="%H%n%ad%n%B---" --date=short 2>/dev/null)
  local diff=$(git diff "$pre_sha"..HEAD)
  local body=$(cat "$HOME/.dotfiles/ralph/review-prompt.md")

  cat <<EOF
<recent-commits>
$commits
</recent-commits>

<iteration-diff>
$diff
</iteration-diff>

$body
EOF
}

for ((i=1; i<=ITERATIONS; i++)); do
  pre_sha=$(git rev-parse HEAD 2>/dev/null || echo "")

  full_prompt=$(build_implement_prompt)
  run_claude "$full_prompt"

  result=$(jq -r "$final_result" "$tmpfile")

  if [[ "$result" == *"<promise>NO MORE TASKS</promise>"* ]]; then
    echo "AFK complete after $i iterations."
    exit 0
  fi

  post_sha=$(git rev-parse HEAD 2>/dev/null || echo "")
  if [[ -n "$pre_sha" && -n "$post_sha" && "$pre_sha" != "$post_sha" ]]; then
    review_prompt=$(build_review_prompt "$pre_sha")
    run_claude "$review_prompt"
  fi
done
