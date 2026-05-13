#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/log.sh"

[ "$(uname -s)" = "Linux" ] || exit 0
command -v systemctl >/dev/null 2>&1 || exit 0

USER_NAME="$(id -un)"

channel="${1:-}"
case "$channel" in
  ""|stable) tag="latest" ;;
  nightly)   tag="nightly" ;;
  *) die "unknown channel '$channel' (use stable|nightly)" ;;
esac

if [ -n "$channel" ] || ! command -v t3 >/dev/null 2>&1; then
  command -v npm >/dev/null 2>&1 || { warn "npm not found; skipping"; exit 0; }
  log "installing t3@$tag"
  npm i -g "t3@$tag" >/dev/null 2>&1 || { warn "npm install failed"; exit 0; }
  command -v mise >/dev/null 2>&1 && mise reshim >/dev/null 2>&1 || true
fi

if command -v tailscale >/dev/null 2>&1 && ! tailscale set --operator="$USER_NAME" >/dev/null 2>&1; then
  warn "run once for Tailscale Serve: sudo tailscale set --operator=$USER_NAME"
fi

if command -v loginctl >/dev/null 2>&1 &&
   [ "$(loginctl show-user "$USER_NAME" 2>/dev/null | sed -n 's/^Linger=//p')" != "yes" ]; then
  warn "run once for boot start: sudo loginctl enable-linger $USER_NAME"
fi

systemctl --user daemon-reload
if ! systemctl --user enable --now t3code.service >/dev/null 2>&1; then
  warn "could not enable t3code.service"
fi

if [ -n "$channel" ]; then
  systemctl --user restart t3code.service >/dev/null 2>&1 || true
  log "using '$channel' channel (t3@$tag)"
fi

desktop_version=$(t3 --version 2>/dev/null | sed -n 's/^t3 v//p' || true)
if [ -n "$desktop_version" ] &&
   ! "$SCRIPT_DIR/setup-t3code-desktop.sh" "$desktop_version"; then
  warn "desktop installation failed; headless server remains configured"
fi
