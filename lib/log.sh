# lib/log.sh — logging + help printing helpers.
#
# All log functions write to stderr so caller functions can echo their value
# to stdout for command substitution capture.

[ -n "${_LIB_LOG_LOADED:-}" ] && return 0
_LIB_LOG_LOADED=1

log()  { echo "[INFO] $*" >&2; }
ok()   { echo "[OK] $*" >&2; }
warn() { echo "[WARN] $*" >&2; }
err()  { echo "[ERROR] $*" >&2; }
die()  { err "$*"; exit 1; }

# Print the USAGE header block from a script file, then exit.
# Args: $1 = path to script (typically "$0" from caller).
print_help_from() {
    sed -n '2,/^# ====/p' "$1" | sed 's/^# \{0,1\}//'
    exit 0
}
