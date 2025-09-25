#!/usr/bin/env bash

# Config
VERSION="${VERSION:-3.45.4}"
URL="${URL:-https://github.com/go-task/task/releases/download/v${VERSION}/task_linux_amd64.tar.gz}"
PREFIX="${PREFIX:-/usr/local/bin}"
BIN_NAME="${BIN_NAME:-task}"
SUDO_CMD=$([ "$(id -u)" -eq 0 ] && echo "" || echo sudo)

# Temp dir
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# Download & extract
curl -fsSL "$URL" -o "$TMP/task.tgz"
tar -xzf "$TMP/task.tgz" -C "$TMP"

# Install
chmod +x "$TMP/task"
$SUDO_CMD install -m 0755 "$TMP/task" "${PREFIX}/${BIN_NAME}"

# Verify
${BIN_NAME}" --version || true