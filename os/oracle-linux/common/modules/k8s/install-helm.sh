#!/usr/bin/env bash

# === Config ===
VERSION="${VERSION:-3.18.6}"
URL="${URL:-https://get.helm.sh/helm-v${VERSION}-linux-amd64.tar.gz}"
PREFIX="${PREFIX:-/usr/local/bin}"
BIN_NAME="${BIN_NAME:-helm}"
SUDO_CMD=$([ "$(id -u)" -eq 0 ] && echo "" || echo sudo)

# === Prep temp ===
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# === Download & extract ===
curl -fsSL "$URL" -o "$TMP/helm.tgz"
tar -xzf "$TMP/helm.tgz" -C "$TMP"

# === Install ===
chmod +x "$TMP/linux-amd64/helm"
$SUDO_CMD install -m 0755 "$TMP/linux-amd64/helm" "${PREFIX}/${BIN_NAME}"

# === Verify ===
"${PREFIX}/${BIN_NAME}" version --short || true