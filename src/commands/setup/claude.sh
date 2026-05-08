skip_config=${args[--skip-config]}
force_config=${args[--force-config]}
skip_plugins=${args[--skip-plugins]}

name="claude"
config_dir="$HOME/.claude"
config_file="$config_dir/settings.json"

echo "Configuring $(cyan_bold "$name")..."
echo ""

# ===================================================================
# Step 1: Check claude installation
# ===================================================================
echo "$(bold "▸ Step 1/3:") Checking claude installation..."

claude_bin=$(command -v claude 2>/dev/null || true)
if [ -z "$claude_bin" ] && [ -f "$HOME/.local/share/mise/shims/claude" ]; then
  claude_bin="$HOME/.local/share/mise/shims/claude"
fi
require_installed "claude" "$claude_bin"
claude_version=$("$claude_bin" --version 2>/dev/null | head -1 || echo "unknown")
echo "$(green_bold "✓") claude found at $claude_bin ($claude_version)"

# ===================================================================
# Step 2: Seed ~/.claude/settings.json
# ===================================================================
echo ""
echo "$(bold "▸ Step 2/3:") Seeding $(cyan "$config_file")..."

if [ -n "$skip_config" ]; then
  echo "$(yellow "⚠") Skipping config (--skip-config)"
else
  mkdir -p "$config_dir"

  if [ -n "$force_config" ] && [ -f "$config_file" ]; then
    # Backup existing config before overwriting
    backup_file="${config_file}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$config_file" "$backup_file"
    echo "$(yellow "⚠") Backed up existing config to $(cyan "$backup_file")"
    rm -f "$config_file"
  fi

  seed_file "$config_file" "$(template_claude_settings)"
fi

# ===================================================================
# Step 3: Install required plugins
# ===================================================================
echo ""
echo "$(bold "▸ Step 3/3:") Installing required plugins..."

if [ -n "$skip_plugins" ]; then
  echo "$(yellow "⚠") Skipping plugins (--skip-plugins)"
else
  # Helper: add marketplace (idempotent — skips if already added)
  _add_marketplace() {
    local source="$1"
    if "$claude_bin" plugin marketplace list 2>/dev/null | grep -q "$source"; then
      echo "  $(yellow "⚠") marketplace $(bold "$source") already added"
    else
      echo "  $(cyan "→") Adding marketplace $(bold "$source")..."
      "$claude_bin" plugin marketplace add "$source" -y 2>/dev/null || true
    fi
  }

  # Helper: install plugin (idempotent — skips if already enabled)
  _install_plugin() {
    local plugin="$1"
    if "$claude_bin" plugin list 2>/dev/null | grep -q "$plugin"; then
      echo "  $(yellow "⚠") $(bold "$plugin") already installed"
    else
      echo "  $(cyan "→") Installing $(bold "$plugin")..."
      "$claude_bin" plugin install "$plugin" -y 2>/dev/null || true
    fi
  }

  # --- Official plugins ---
  echo ""
  echo "  $(bold "Official plugins:")"
  _install_plugin "frontend-design@claude-plugins-official"

  # --- Superpowers ---
  echo ""
  echo "  $(bold "Superpowers:")"
  _add_marketplace "obra/superpowers-marketplace"
  _install_plugin "superpowers@superpowers-marketplace"

  # --- Claude-Mem ---
  echo ""
  echo "  $(bold "Claude-Mem:")"
  _add_marketplace "thedotmack/claude-mem"
  _install_plugin "claude-mem@thedotmack"

  echo ""
  echo "$(green_bold "✓") Plugins installed"
fi

# ===================================================================
# Summary
# ===================================================================
echo ""
echo "$(green_bold "━━━ Configuration complete ━━━")"
echo ""
echo "Next steps:"
echo "  1. Login:            $(bold "claude login")"
echo "  2. Edit settings:    $(bold "vim $config_file")"
echo "  3. Manage plugins:   $(bold "claude plugin list")"
echo "  4. Start coding:     $(bold "claude")"
echo "  5. Docs:             $(bold "https://docs.anthropic.com/en/docs/claude-code")"

