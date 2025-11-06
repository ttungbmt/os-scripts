#!/bin/bash
# =============================================================================
# DBT — 
#
# USAGE (recommended):
#   VERSION=0.40.8 \
#   bash <(curl -fsSL "https://raw.githubusercontent.com/ttungbmt/os-scripts/refs/heads/master/common/modules/tools/install-dbt.sh")
#
# VARIABLES (override via env):
#   VERSION  : release version (default: 0.40.8)
# =============================================================================

set -euo pipefail

GH_LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/dbt-labs/dbt-cli/releases/latest | sed -e 's/.*"tag_name":"v\([^"]*\)".*/\1/')

# --- Defaults (user-tunable) ---
VERSION="${VERSION:-$GH_LATEST_VERSION}"

# --- Vars (rarely changed) ---
OS="linux"
ARCH="amd64"
URL="${URL:-https://github.com/dbt-labs/dbt-cli/releases/download/v${VERSION}/dbt_${VERSION}_${OS}_${ARCH}.tar.gz}"
BIN_DIR="${DIR:-/usr/local/bin}"
BIN_NAME="${BIN_NAME:-dbt}"
SUDO_CMD=$([ "$(id -u)" -eq 0 ] && echo "" || echo sudo)

# --- Temp dir (auto-clean) ---
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# --- Download & extract ---
ARCHIVE="$TMP/${BIN_NAME}.tgz"
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

