#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/log.sh"

[ "$(uname -s)" = "Darwin" ] || { warn "macOS only"; exit 0; }

label="com.mapring.ubuntu"
plist="$HOME/Library/LaunchAgents/$label.plist"
ssh_host="ubuntu"
domain="gui/$(id -u)"
ports=(3000)

usage() {
  cat >&2 <<EOF
Usage: setup-tunnel.sh install      write the launchd agent and start it (always-on)
       setup-tunnel.sh uninstall    stop and remove it entirely
       setup-tunnel.sh off          stop it for now (frees localhost ports for local dev)
       setup-tunnel.sh on           start it again
       setup-tunnel.sh status       show whether it's running (default)
EOF
}

case "${1:-status}" in
  -h|--help|help)
    usage
    ;;
  install)
    command -v autossh >/dev/null 2>&1 || die "autossh not installed (brew install autossh)"
    mkdir -p "$(dirname "$plist")"
    forwards=""
    for port in "${ports[@]}"; do
      forwards+="    <string>-L</string><string>$port:localhost:$port</string>"$'\n'
    done
    cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$label</string>
  <key>ProgramArguments</key>
  <array>
    <string>$(command -v autossh)</string>
    <string>-M</string><string>0</string>
    <string>-N</string>
    <string>-o</string><string>ControlMaster=no</string>
    <string>-o</string><string>ControlPath=none</string>
${forwards}    <string>$ssh_host</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict><key>AUTOSSH_GATETIME</key><string>0</string></dict>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardErrorPath</key><string>/tmp/$label.log</string>
  <key>StandardOutPath</key><string>/tmp/$label.log</string>
</dict>
</plist>
EOF
    launchctl bootout "$domain/$label" 2>/dev/null || true
    launchctl bootstrap "$domain" "$plist"
    log "installed and running ($label)"
    ;;
  uninstall)
    launchctl bootout "$domain/$label" 2>/dev/null || true
    rm -f "$plist"
    log "uninstalled"
    ;;
  on|start|up)
    [ -f "$plist" ] || die "not installed; run 'scripts/setup-tunnel.sh install'"
    launchctl bootout "$domain/$label" 2>/dev/null || true
    launchctl bootstrap "$domain" "$plist"
    log "started"
    ;;
  off|stop|down)
    launchctl bootout "$domain/$label" 2>/dev/null || true
    log "stopped (starts again at login; use 'uninstall' to remove)"
    ;;
  status)
    if launchctl print "$domain/$label" >/dev/null 2>&1; then
      log "running ($label)"
    else
      log "not running"
    fi
    ;;
  *)
    error "unknown command '$1'"
    usage
    exit 1
    ;;
esac
