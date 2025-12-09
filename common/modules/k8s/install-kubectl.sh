#!/usr/bin/env bash

# === Config ===
VERSION="${VERSION:-1.34.0}"
URL="${URL:-https://dl.k8s.io/release/v${VERSION}/bin/linux/amd64/kubectl}"
PREFIX="${PREFIX:-/usr/local/bin}"
BIN_NAME="${BIN_NAME:-kubectl}"
SUDO_CMD=$([ "$(id -u)" -eq 0 ] && echo "" || echo sudo)

# === Prep temp ===
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# === Download ===
curl -fsSL "$URL" -o "$TMP/${BIN_NAME}"
chmod +x "$TMP/${BIN_NAME}"

# === Install ===
$SUDO_CMD install -m 0755 "$TMP/${BIN_NAME}" "${PREFIX}/${BIN_NAME}"

# === Verify ===
"${PREFIX}/${BIN_NAME}" version --client --short || true