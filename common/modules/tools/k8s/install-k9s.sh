#!/bin/bash
# =============================================================================
# K9S Installer — 
#
# USAGE (recommended):
#   VERSION=0.50.9 \
#   bash <(curl -fsSL "https://raw.githubusercontent.com/ttungbmt/os-scripts/refs/heads/master/common/modules/tools/k8s/install-k9s.sh")
#
# VARIABLES (override via env):
#   VERSION  : release version (default: 3.45.4)
# =============================================================================

set -euo pipefail

GH_LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/derailed/k9s/releases/latest | sed -e 's/.*"tag_name":"v\([^"]*\)".*/\1/')

# --- Defaults (user-tunable) ---
VERSION="${VERSION:-$GH_LATEST_VERSION}"

# --- Vars (rarely changed) ---
OS="linux"
ARCH="amd64"
URL="${URL:-https://github.com/derailed/k9s/releases/download/v${VERSION}/k9s_${OS^}_${ARCH}.tar.gz}"
BIN_DIR="${DIR:-/usr/local/bin}"
BIN_NAME="${BIN_NAME:-k9s}"
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
$SUDO_CMD install -m 0755 "$BIN_PATH" "${BIN_DIR}/${BIN_NAME}"
echo "[OK] Installed ${BIN_DIR}/${BIN_NAME}"

# --- Verify ---
"${BIN_NAME}" --version || true

