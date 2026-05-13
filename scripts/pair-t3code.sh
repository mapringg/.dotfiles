#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/log.sh"

[ "$(uname -s)" = "Linux" ] || { warn "Linux only"; exit 0; }
command -v t3 >/dev/null 2>&1 || die "t3 not installed"

connection="${1:-local}"
case "$connection" in
  local)
    base="http://127.0.0.1:3773"
    ;;
  tailscale)
    command -v tailscale >/dev/null 2>&1 || die "tailscale not installed"
    base=$(tailscale serve status 2>/dev/null | grep -oE 'https://[^ ]+' | head -1)
    [ -n "$base" ] || die "could not find the Tailscale Serve URL"
    ;;
  *)
    die "unknown connection '$connection' (use local|tailscale)"
    ;;
esac

token=$(T3CODE_HOME="$HOME/.local/share/t3code" t3 auth pairing create 2>/dev/null | awk '/^Token:/ {print $2}')

[ -n "$token" ] || die "could not create pairing token"

printf '%s\n' "${base}/pair#token=${token}"
