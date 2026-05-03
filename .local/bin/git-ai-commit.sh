#!/bin/bash
set -eo pipefail

mode=${1:-commit}

case "$mode" in
  commit)
    diff=$(git diff --cached)
    [ -z "$diff" ] && { echo "No staged changes." >&2; exit 1; }
    ;;
  regenerate)
    sha=${2:?missing commit sha}
    diff=$(git show --format= "$sha")
    [ -z "$diff" ] && { echo "No diff for $sha." >&2; exit 1; }
    ;;
  *)
    echo "Usage: $0 [commit|regenerate <sha>]" >&2
    exit 1
    ;;
esac

prompt=$(cat <<'PROMPT'
Generate a Conventional Commits message for the diff below.

Rules:
- Format: <type>(<scope>): <subject>  (scope optional)
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Imperative mood, present tense ("add" not "added" or "adds")
- Subject <=72 chars, lowercase first letter, no trailing period
- Output exactly one line: the commit message. No quotes, no backticks, no code fences, no preamble, no explanation.

Examples:
feat(auth): add oauth2 login flow
fix(api): handle null response from upstream
refactor(parser): extract token classification helper
chore(deps): bump lodash to 4.17.21
docs: clarify install steps for macOS
test(billing): cover annual plan proration

Diff:
PROMPT
)

raw=$(printf '%s\n```diff\n%s\n```\n' "$prompt" "$diff" \
  | claude -p --model haiku 2>/dev/null)

msg=$(echo "$raw" | grep -E '^[[:space:]]*[a-z]+(\([^)]+\))?!?:' | head -n 1 \
  | sed -E 's/^[[:space:]]*//; s/[[:space:]]*$//; s/\.$//')
if [ -z "$msg" ]; then
  msg=$(echo "$raw" | awk 'NF{last=$0} END{print last}' \
    | sed -E 's/^[[:space:]]*[`"]+//; s/[`"]+[[:space:]]*$//; s/\.$//')
fi

[ -z "$msg" ] && { echo "Failed to generate commit message." >&2; exit 1; }

if [ "$mode" = "commit" ]; then
  git commit -m "$msg"
else
  printf '%s\n' "$msg"
fi
