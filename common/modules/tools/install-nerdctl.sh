#!/usr/bin/env bash
# =============================================================================
# nerdctl Installer — installs `nerdctl` from official tarball
#
# USAGE (recommended):
#   VERSION=2.1.6 \
#   bash <(curl -fsSL "https://raw.githubusercontent.com/ttungbmt/os-scripts/refs/heads/master/common/modules/tools/install-nerdctl.sh")
#
# VARIABLES (override via env):
#   VERSION      : release version (default: 2.1.6)
#   PREFIX       : install prefix (default: /usr/local/bin)
#   BIN_NAME     : binary name (default: nerdctl)
#   URL          : override download URL (normally auto-built from VERSION/ARCH)
# =============================================================================

# --- Defaults (user-tunable) ---
VERSION="${VERSION:-2.1.6}"
PREFIX="${PREFIX:-/usr/local/bin}"
BIN_NAME="${BIN_NAME:-nerdctl}"

# --- Vars (rarely changed) ---
URL="${URL:-https://github.com/containerd/nerdctl/releases/download/v${VERSION}/nerdctl-${VERSION}-linux-amd64.tar.gz}"
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

# --- Install binary ---
chmod +x "$BIN_PATH"
$SUDO_CMD install -m 0755 "$BIN_PATH" "${PREFIX}/${BIN_NAME}"
echo "[OK] Installed ${PREFIX}/${BIN_NAME}"

# --- Verify ---
"${BIN_NAME}" --version || true
