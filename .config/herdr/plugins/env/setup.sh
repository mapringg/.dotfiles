#!/usr/bin/env bash

set -euo pipefail

checkout_path=$(
  python3 - <<'PY'
import json
import os

context = json.loads(os.environ["HERDR_PLUGIN_CONTEXT_JSON"])
worktree = context.get("worktree") or {}
if worktree.get("is_linked_worktree"):
    print(worktree.get("checkout_path") or context.get("workspace_cwd", ""))
PY
)

if [[ -z $checkout_path || ! -d $checkout_path ]]; then
  exit 0
fi

current_root=$(cd -- "$checkout_path" && pwd -P)
common_dir=$(git -C "$current_root" rev-parse --git-common-dir 2>/dev/null) || exit 0
case $common_dir in
  /*) ;;
  *) common_dir="$current_root/$common_dir" ;;
esac

project_root=$(cd -- "$(dirname -- "$common_dir")" && pwd -P)

find "$project_root" \
  -path "$project_root/.git" -prune -o \
  -path '*/node_modules' -prune -o \
  -type f -name .env -print |
  while IFS= read -r source_env; do
    relative_path=${source_env#"$project_root"/}
    target_env="$current_root/$relative_path"

    if [[ ! -e $target_env && ! -L $target_env ]]; then
      target_dir=$(dirname -- "$target_env")
      if mkdir -p "$target_dir" && cp -p "$source_env" "$target_env"; then
        continue
      fi
      printf '%s\n' "warning: could not copy $source_env to $target_env" >&2
    fi
  done
