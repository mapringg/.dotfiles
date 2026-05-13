#!/usr/bin/env bash

read -r tokens limit < <(jq -r '
  (.context_window // {}) as $c
  | "\($c.total_input_tokens // 0) \($c.context_window_size // 200000)"
')

if ((tokens >= 1000)); then
  display=$(awk -v t="$tokens" 'BEGIN { printf "%.1fk", t/1000 }')
else
  display="$tokens"
fi

pct=$(awk -v t="$tokens" -v l="$limit" 'BEGIN { printf "%.1f", (t/l)*100 }')

printf '\033[33m%s\033[0m (%s%%)' "$display" "$pct"
