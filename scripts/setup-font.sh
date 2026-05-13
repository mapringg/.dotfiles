#!/usr/bin/env bash
set -euo pipefail

[ "$(uname -s)" = "Linux" ] || {
  echo "setup-font: not Linux, skipping."
  exit 0
}

# Geist for the GNOME desktop UI font, GeistMono Nerd Font Mono for monospace.
# Pinned to a release tag (SIL OFL).
GEIST_VERSION="v1.7.2"
GEIST_MONO_NERD_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/GeistMono.zip"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
WEIGHTS=(Thin UltraLight Light Regular Medium SemiBold Bold Black UltraBlack)

command -v gsettings >/dev/null 2>&1 || {
  echo "setup-font: gsettings not found (not a GNOME session?); skipping." >&2
  exit 0
}

CHANGED=0

# install_family <file-prefix> <repo-subdir> <dest-dir>
install_family() {
  local prefix="$1" subdir="$2" dir="$3"
  local base="https://raw.githubusercontent.com/vercel/geist-font/$GEIST_VERSION/packages/next/dist/fonts/$subdir"
  mkdir -p "$dir"
  local w dst
  for w in "${WEIGHTS[@]}"; do
    dst="$dir/${prefix}-$w.ttf"
    [ -f "$dst" ] && continue
    echo "setup-font: installing ${prefix}-$w $GEIST_VERSION..."
    if ! curl -fsSL "$base/${prefix}-$w.ttf" -o "$dst"; then
      echo "setup-font: failed to download ${prefix}-$w.ttf; skipping that weight." >&2
      rm -f "$dst"
    else
      CHANGED=1
    fi
  done
  [ -f "$dir/${prefix}-Regular.ttf" ]
}

install_geist_mono_nerd() {
  local dir="$1" prefix="GeistMonoNerdFontMono" ext="otf"
  local w missing=0
  mkdir -p "$dir"
  for w in "${WEIGHTS[@]}"; do
    [ -f "$dir/${prefix}-$w.$ext" ] || missing=1
  done
  [ "$missing" = 0 ] && return 0

  command -v unzip >/dev/null 2>&1 || {
    echo "setup-font: unzip not found; cannot install GeistMono Nerd Font Mono." >&2
    return 1
  }

  local tmp zip
  tmp="$(mktemp -d)"
  zip="$tmp/GeistMono.zip"
  echo "setup-font: installing GeistMono Nerd Font Mono..."
  if curl -fsSL "$GEIST_MONO_NERD_URL" -o "$zip" \
    && unzip -j -o "$zip" "${prefix}-*.$ext" -d "$dir" >/dev/null; then
    rm -rf "$tmp"
    CHANGED=1
    [ -f "$dir/${prefix}-Regular.$ext" ]
  else
    echo "setup-font: failed to install GeistMono Nerd Font Mono." >&2
    rm -rf "$tmp"
    return 1
  fi
}

# apply_family <gsettings-key> <family>: swap the family, keep the current size.
apply_family() {
  local key="$1" family="$2" cur size
  cur="$(gsettings get org.gnome.desktop.interface "$key" 2>/dev/null | tr -d "'")"
  size="$(printf '%s' "$cur" | grep -oE '[0-9]+$' || true)"
  gsettings set org.gnome.desktop.interface "$key" "$family ${size:-11}"
}

OK=1
install_family Geist     geist-sans "$DATA/fonts/Geist"     || OK=0
install_geist_mono_nerd "$DATA/fonts/GeistMonoNerdFontMono" || OK=0
[ "$CHANGED" = 1 ] && { command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$DATA/fonts" >/dev/null 2>&1 || true; }

[ "$OK" = 1 ] || { echo "setup-font: fonts incomplete; not applying GNOME settings." >&2; exit 1; }

apply_family font-name           "Geist"
apply_family monospace-font-name "GeistMono Nerd Font Mono"

echo "setup-font: done -> ui $(gsettings get org.gnome.desktop.interface font-name), mono $(gsettings get org.gnome.desktop.interface monospace-font-name)"
