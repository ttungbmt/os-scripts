#!/usr/bin/env bash
# =============================================================================
# Task Installer — installs `task` from official tarball
#
# USAGE (recommended):
#   VERSION=3.45.4 \
#   bash <(curl -fsSL "https://raw.githubusercontent.com/ttungbmt/os-scripts/refs/heads/master/common/modules/tools/install-tash.sh")
#
# VARIABLES (override via env):
#   VERSION  : release version (default: 3.45.4)
# =============================================================================

set -euo pipefail

# --- Defaults (user-tunable) ---
VERSION="${VERSION:-3.45.4}"

# --- Vars (rarely changed) ---
URL="${URL:-https://github.com/go-task/task/releases/download/v${VERSION}/task_linux_amd64.tar.gz}"
PREFIX="${PREFIX:-/usr/local/bin}"
BIN_NAME="${BIN_NAME:-task}"
SUDO_CMD=$([ "$(id -u)" -eq 0 ] && echo "" || echo sudo)

# --- Temp dir (auto-clean) ---
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# --- Download & extract ---
ARCHIVE="$TMP/task.tgz"
curl -fsSL "$URL" -o "$ARCHIVE"
tar -xzf "$ARCHIVE" -C "$TMP"

# --- Locate binary (handles nested folder in tar) ---
BIN_PATH=""
if [ -x "$TMP/$BIN_NAME" ]; then
  BIN_PATH="$TMP/$BIN_NAME"
else
  BIN_PATH="$(find "$TMP" -maxdepth 3 -type f -name "$BIN_NAME" -perm -u+x | head -n1 || true)"
fi

if [ -z "$BIN_PATH" ]; then
  echo "[ERROR] Binary '$BIN_NAME' not found in archive."
  exit 1
fi

# --- Install ---
chmod +x "$BIN_PATH"
$SUDO_CMD install -m 0755 "$BIN_PATH" "${PREFIX}/${BIN_NAME}"
echo "[OK] Installed ${PREFIX}/${BIN_NAME}"

# --- Verify ---
"${BIN_NAME}" --version || true
