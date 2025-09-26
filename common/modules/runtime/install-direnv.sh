#!/usr/bin/env bash

# Config
VERSION="${VERSION:-2.34.0}"
URL="${URL:-https://github.com/direnv/direnv/releases/download/v${VERSION}/direnv.linux-amd64}"
BIN_NAME="${BIN_NAME:-direnv}"

PREFIX="${PREFIX:-/usr/local/bin}"
SUDO_CMD=$([ "$(id -u)" -eq 0 ] && echo "" || echo sudo)

# Temp dir
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# Download
curl -fsSL "$URL" -o "$TMP/${BIN_NAME}"

# Install
chmod +x "$TMP/${BIN_NAME}"
$SUDO_CMD install -m 0755 "$TMP/${BIN_NAME}" "${PREFIX}/${BIN_NAME}"

# Verify
"${BIN_NAME}" version || true

# Hook direnv into your shell.
[ -f ~/.bashrc ] && grep -Fxq 'eval "$(direnv hook bash)"' ~/.bashrc || { [ -f ~/.bashrc ] && printf '\n# direnv\n%s\n' 'eval "$(direnv hook bash)"' >> ~/.bashrc; }
[ -f ~/.zshrc ] && grep -Fxq 'eval "$(direnv hook zsh)"' ~/.zshrc || { [ -f ~/.zshrc ] && printf '\n# direnv\n%s\n' 'eval "$(direnv hook zsh)"' >> ~/.zshrc; }