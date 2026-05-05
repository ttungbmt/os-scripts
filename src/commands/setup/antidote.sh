skip_plugins=${args[--skip-plugins]}
force_plugins=${args[--force-plugins]}
skip_zshrc=${args[--skip-zshrc]}

name="antidote"
zsh_plugins_file="${ZDOTDIR:-$HOME}/.zsh_plugins.txt"
zshrc="${ZDOTDIR:-$HOME}/.zshrc"

echo "Configuring $(cyan_bold "$name")..."
echo ""

# ===================================================================
# Step 1: Check antidote installation
# ===================================================================
echo "$(bold "▸ Step 1/3:") Checking antidote installation..."

antidote_path="/usr/local/share/antidote/antidote.zsh"
if [ ! -f "$antidote_path" ] && [ -f "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh" ]; then
  antidote_path="${ZDOTDIR:-$HOME}/.antidote/antidote.zsh"
fi

require_installed "antidote" "$antidote_path"
echo "$(green_bold "✓") antidote found at $antidote_path"

# ===================================================================
# Step 2: Configure ~/.zshrc
# ===================================================================
echo ""
echo "$(bold "▸ Step 2/3:") Configuring $(cyan "$zshrc")..."

ANTIDOTE_MARKER="# --- antidote bootstrap (managed by os-scripts) ---"

if [ -n "$skip_zshrc" ]; then
  echo "$(yellow "⚠") Skipping .zshrc configuration (--skip-zshrc)"
else
  inject_config_block "$zshrc" "$ANTIDOTE_MARKER" "$(template_antidote_zshrc)"
fi

# ===================================================================
# Step 3: Seed ~/.zsh_plugins.txt
# ===================================================================
echo ""
echo "$(bold "▸ Step 3/3:") Seeding $(cyan "$zsh_plugins_file")..."

if [ -n "$skip_plugins" ]; then
  echo "$(yellow "⚠") Skipping plugin seeding (--skip-plugins)"
else
  if [ -n "$force_plugins" ] && [ -f "$zsh_plugins_file" ]; then
    rm -f "$zsh_plugins_file"
  fi
  seed_file "$zsh_plugins_file" "$(template_antidote_plugins)"
fi

# ===================================================================
# Summary
# ===================================================================
echo ""
echo "$(green_bold "━━━ Configuration complete ━━━")"
echo ""
echo "Next steps:"
echo "  1. Start a new zsh session:  $(bold "exec zsh")"
echo "  2. Edit plugins:             $(bold "vim $zsh_plugins_file")"
echo "  3. Update plugins:           $(bold "antidote update")"
echo "  4. Docs:                     $(bold "docs/antidote-deployment.md")"
