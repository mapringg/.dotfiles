#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/log.sh"

[ "$(uname -s)" = "Linux" ] || { warn "Linux only"; exit 0; }

case "$(uname -m)" in
  x86_64|amd64) appimage_arch="x86_64" ;;
  *)
    warn "no Linux AppImage for $(uname -m)"
    exit 0
    ;;
esac

version="${1:-}"
if [ -z "$version" ]; then
  command -v t3 >/dev/null 2>&1 || {
    die "t3 CLI is required to select a desktop version"
  }
  version=$(t3 --version 2>/dev/null | sed -n 's/^t3 v//p' || true)
fi

case "$version" in
  ""|*[!0-9A-Za-z._-]*)
    die "could not determine a safe T3 Code version"
    ;;
esac

install_dir="$HOME/.local/opt/t3-code"
appimage="$install_dir/T3-Code.AppImage"
app_dir="$install_dir/app"
launcher="$app_dir/AppRun"
version_file="$install_dir/version"
desktop_dir="$HOME/.local/share/applications"
desktop_file="$desktop_dir/t3-code.desktop"
icon_dir="$HOME/.local/share/icons"
icon_path="applications-development"
installed_now=false

install -d "$install_dir" "$desktop_dir" "$icon_dir"

for existing_icon in "$icon_dir/t3-code.png" "$icon_dir/t3-code.svg" "$icon_dir/t3-code.xpm"; do
  if [ -f "$existing_icon" ]; then
    icon_path="$existing_icon"
    break
  fi
done

installed_version=""
[ -f "$version_file" ] && installed_version=$(sed -n '1p' "$version_file")

if [ "$installed_version" != "$version" ] || [ ! -x "$appimage" ]; then
  command -v curl >/dev/null 2>&1 || die "curl is required"
  command -v jq >/dev/null 2>&1 || die "jq is required"
  command -v sha256sum >/dev/null 2>&1 || die "sha256sum is required"

  asset="T3-Code-${version}-${appimage_arch}.AppImage"
  release_api="https://api.github.com/repos/pingdotgg/t3code/releases/tags/v${version}"
  release_json=$(curl -fsSL --retry 3 "$release_api") || {
    die "no desktop release found for v$version"
  }
  asset_metadata=$(
    printf '%s' "$release_json" |
      jq -r --arg asset "$asset" \
        '.assets[] | select(.name == $asset) | [.browser_download_url, .digest] | @tsv'
  )
  IFS=$'\t' read -r url digest <<< "$asset_metadata"
  if [ -z "${url:-}" ] || [[ "${digest:-}" != sha256:* ]]; then
    die "release v$version has no verified $asset asset"
  fi

  download=$(mktemp "$install_dir/.T3-Code.AppImage.XXXXXX")

  cleanup_download() {
    rm -f "$download"
  }
  trap cleanup_download EXIT

  log "installing v$version"
  if ! curl -fL --retry 3 --progress-bar "$url" -o "$download"; then
    die "failed to download v$version"
  fi
  expected_sha256="${digest#sha256:}"
  if ! printf '%s  %s\n' "$expected_sha256" "$download" | sha256sum --check --status; then
    die "AppImage checksum verification failed"
  fi

  chmod 0755 "$download"
  mv -f "$download" "$appimage"
  printf '%s\n' "$version" > "$version_file"
  trap - EXIT
  installed_now=true
else
  log "v$version already installed"
fi

# Avoid the legacy FUSE 2 dependency by launching the extracted AppImage.
if [ "$installed_now" = true ] || [ ! -x "$launcher" ]; then
  extract_dir=$(mktemp -d "$install_dir/.extract.XXXXXX")

  cleanup_extract() {
    rm -rf "$extract_dir"
  }
  trap cleanup_extract EXIT

  log "extracting application"
  if ! (
    cd "$extract_dir"
    "$appimage" --appimage-extract >/dev/null 2>&1
  ); then
    die "could not extract the AppImage"
  fi
  if [ ! -x "$extract_dir/squashfs-root/AppRun" ]; then
    die "extracted release has no executable AppRun"
  fi

  rm -rf "$app_dir"
  mv "$extract_dir/squashfs-root" "$app_dir"
  rm -rf "$extract_dir"
  trap - EXIT
fi

extracted_icon="$app_dir/.DirIcon"
if [ -e "$extracted_icon" ]; then
  icon_source=$(readlink -f "$extracted_icon")
  icon_extension="${icon_source##*.}"
  case "$icon_extension" in
    png|svg|xpm)
      icon_path="$icon_dir/t3-code.$icon_extension"
      install -m 0644 "$icon_source" "$icon_path"
      ;;
  esac
fi

cat > "$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Name=T3 Code
Comment=Code with agents
Exec="$launcher" %U
TryExec=$launcher
Icon=$icon_path
Terminal=false
Categories=Development;IDE;
StartupNotify=true
StartupWMClass=t3code
EOF

command -v update-desktop-database >/dev/null 2>&1 &&
  update-desktop-database "$desktop_dir" >/dev/null 2>&1 || true

log "installed v$version"
log "pair with the Linux backend using scripts/pair-t3code.sh"
