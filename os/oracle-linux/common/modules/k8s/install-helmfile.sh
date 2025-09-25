#!/usr/bin/env bash

# === Config ===
VERSION="${VERSION:-1.1.7}"
URL="${URL:-https://github.com/helmfile/helmfile/releases/download/v${VERSION}/helmfile_${VERSION}_linux_amd64.tar.gz}"
PREFIX="${PREFIX:-/usr/local/bin}"
BIN_NAME="${BIN_NAME:-helmfile}"
SUDO_CMD=$([ "$(id -u)" -eq 0 ] && echo "" || echo sudo)

# === Prep temp ===
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# === Download & extract ===
curl -fsSL "$URL" -o "$TMP/hf.tgz"
tar -xzf "$TMP/hf.tgz" -C "$TMP"

# === Install ===
chmod +x "$TMP/helmfile"
$SUDO_CMD install -m 0755 "$TMP/helmfile" "${PREFIX}/${NAME}"

# === Verify ===
"${PREFIX}/${NAME}" --version || true