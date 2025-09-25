#!/usr/bin/env bash

# === Config ===
VERSION="${VERSION:-0.50.9}"
URL="${URL:-https://github.com/derailed/k9s/releases/download/v${VERSION}/k9s_Linux_amd64.tar.gz}"
PREFIX="${PREFIX:-/usr/local/bin}"
BIN_NAME="${BIN_NAME:-k9s}"
SUDO_CMD=$([ "$(id -u)" -eq 0 ] && echo "" || echo sudo)

# === Prep temp ===
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# === Download & extract ===
curl -fsSL "$URL" -o "$TMP/k9s.tgz"
tar -xzf "$TMP/k9s.tgz" -C "$TMP"

# === Install ===
chmod +x "$TMP/k9s"
$SUDO_CMD install -m 0755 "$TMP/k9s" "${PREFIX}/${BIN_NAME}"

# === Verify ===
"${PREFIX}/${BIN_NAME}" version || true
