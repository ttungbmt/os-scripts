#!/usr/bin/env bash
# =============================================================================
# UV Installer (gnu build) — installs `uv` and/or `uvx` from the official tarball
#
# USAGE (recommended):
#   # Override via env vars, then run with process substitution
#   VERSION=0.8.22 \
#   bash <(curl -fsSL "https://raw.githubusercontent.com/ttungbmt/os-scripts/refs/heads/master/common/modules/devtools/install-uv.sh")
#
# VARIABLES:
#   VERSION     : uv release version (default: 0.8.22)
#
# =============================================================================
set -euo pipefail

# --- Defaults (can be overridden by env) ---
VERSION="${VERSION:-0.8.22}"

# --- Vars (can be overridden by env) ---
URL="${URL:-https://github.com/astral-sh/uv/releases/download/${VERSION}/uv-x86_64-unknown-linux-gnu.tar.gz}"
BIN_NAMES=(${BIN_NAMES:-uv uvx})
PREFIX="${PREFIX:-/usr/local/bin}"
SUDO_CMD=$([ "$(id -u)" -eq 0 ] && echo "" || echo sudo)

# --- Temp workspace (auto-clean on exit) ---
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# --- Download archive ---
curl -fsSL "$URL" -o "$TMP/uv.tgz"

# --- Extract files ---
tar -xzf "$TMP/uv.tgz" -C "$TMP"

# --- Install requested binaries ---
for name in "${BIN_NAMES[@]}"; do
  BIN_PATH=""
  # Try common locations first; fall back to find
  if [ -x "$TMP/$name" ]; then
    BIN_PATH="$TMP/$name"
  else
    BIN_PATH="$(find "$TMP" -maxdepth 3 -type f -name "$name" -perm -u+x | head -n1 || true)"
  fi

  if [ -z "$BIN_PATH" ]; then
    echo "[ERROR] Binary '$name' not found in archive."
    exit 1
  fi

  $SUDO_CMD install -m 0755 "$BIN_PATH" "${PREFIX}/${name}"
  echo "[OK] Installed ${PREFIX}/${name}"
done

# --- Verify installation (best-effort) ---
command -v uv >/dev/null 2>&1 && uv --version || true
command -v uvx >/dev/null 2>&1 && uvx --version || true
