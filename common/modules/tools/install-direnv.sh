#!/usr/bin/env bash
# =============================================================================
# direnv Installer — installs direnv and hooks into bash/zsh
#
# USAGE (recommended):
#   # Override via env vars if needed, then run with process substitution
#   VERSION=2.34.0 \
#   bash <(curl -fsSL "https://raw.githubusercontent.com/ttungbmt/os-scripts/refs/heads/master/common/modules/tools/install-direnv.sh")
#
# VARIABLES (override via env):
#   VERSION   : direnv release version (default: 2.34.0)
# =============================================================================

# --- Defaults (user-tunable) ---
VERSION="${VERSION:-2.34.0}"

# --- Vars (rarely changed) ---
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

if [ -n "${BASH_VERSION:-}" ]; then
    [ -f "$HOME/.bashrc" ] && echo "👉 Run: source ~/.bashrc  (or: exec bash)"
elif [ -n "${ZSH_VERSION:-}" ]; then
    [ -f "$HOME/.zshrc" ] && echo "👉 Run: source ~/.zshrc  (or: exec zsh)"
else
    echo "👉 Open a new shell or source your shell rc file manually."
fi