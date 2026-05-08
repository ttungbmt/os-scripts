skip_config=${args[--skip-config]}
force_config=${args[--force-config]}

name="claude"
config_dir="$HOME/.claude"
config_file="$config_dir/settings.json"

echo "Configuring $(cyan_bold "$name")..."
echo ""

# ===================================================================
# Step 1: Check claude installation
# ===================================================================
echo "$(bold "▸ Step 1/2:") Checking claude installation..."

claude_bin=$(command -v claude 2>/dev/null || true)
require_installed "claude" "$claude_bin"
claude_version=$(claude --version 2>/dev/null | head -1 || echo "unknown")
echo "$(green_bold "✓") claude found at $claude_bin ($claude_version)"

# ===================================================================
# Step 2: Seed ~/.claude/settings.json
# ===================================================================
echo ""
echo "$(bold "▸ Step 2/2:") Seeding $(cyan "$config_file")..."

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
# Summary
# ===================================================================
echo ""
echo "$(green_bold "━━━ Configuration complete ━━━")"
echo ""
echo "Next steps:"
echo "  1. Login:            $(bold "claude login")"
echo "  2. Edit settings:    $(bold "vim $config_file")"
echo "  3. Start coding:     $(bold "claude")"
echo "  4. Docs:             $(bold "https://docs.anthropic.com/en/docs/claude-code")"
