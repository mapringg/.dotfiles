LOG_NAME="${BASH_SOURCE[1]##*/}"
LOG_NAME="${LOG_NAME%.sh}"

log() { printf '%s: %s\n' "$LOG_NAME" "$*"; }
warn() { printf '%s: warning: %s\n' "$LOG_NAME" "$*" >&2; }
error() { printf '%s: error: %s\n' "$LOG_NAME" "$*" >&2; }
die() { error "$@"; exit 1; }
