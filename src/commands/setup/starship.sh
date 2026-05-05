preset=${args[--preset]}
skip_config=${args[--skip-config]}
skip_shell=${args[--skip-shell]}
force_config=${args[--force-config]}

name="starship"
config_file="${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml}"
zshrc="${ZDOTDIR:-$HOME}/.zshrc"
bashrc="$HOME/.bashrc"

STARSHIP_MARKER="# --- starship init (managed by os-scripts) ---"

echo "Configuring $(cyan_bold "$name")..."
echo ""

# ===================================================================
# Step 1: Check starship installation
# ===================================================================
echo "$(bold "▸ Step 1/3:") Checking starship installation..."

starship_bin=$(command -v starship 2>/dev/null || true)
require_installed "starship" "$starship_bin"
starship_version=$(starship --version 2>/dev/null | awk 'NR==1 {print $2}')
echo "$(green_bold "✓") starship found at $starship_bin (v${starship_version:-unknown})"

# ===================================================================
# Step 2: Seed ~/.config/starship.toml
# ===================================================================
echo ""
echo "$(bold "▸ Step 2/3:") Seeding $(cyan "$config_file")..."

if [ -n "$skip_config" ]; then
  echo "$(yellow "⚠") Skipping config (--skip-config)"
else
  mkdir -p "$(dirname "$config_file")"

  if [ -n "$force_config" ] && [ -f "$config_file" ]; then
    rm -f "$config_file"
  fi

  if [ -n "$preset" ]; then
    if [ -s "$config_file" ]; then
      echo "$(yellow "⚠") $config_file already has content — use $(bold --force-config) to overwrite"
    elif starship preset "$preset" -o "$config_file" 2>/dev/null; then
      echo "$(green_bold "✓") Applied preset $(bold "$preset") to $config_file"
    else
      echo "$(red "✗") Unknown preset: $(bold "$preset")"
      echo "  Run $(bold "starship preset list") to see available presets."
      exit 1
    fi
  else
    seed_file "$config_file" "$(template_starship_config)"
  fi
fi

# ===================================================================
# Step 3: Inject init line into shell rc files
# ===================================================================
echo ""
echo "$(bold "▸ Step 3/3:") Configuring shell init..."

if [ -n "$skip_shell" ]; then
  echo "$(yellow "⚠") Skipping shell init (--skip-shell)"
else
  if [ -f "$zshrc" ]; then
    inject_config_block "$zshrc" "$STARSHIP_MARKER" "$(template_starship_zshrc)"
  else
    echo "$(yellow "⚠") $zshrc does not exist — skipping zsh"
  fi

  if [ -f "$bashrc" ]; then
    inject_config_block "$bashrc" "$STARSHIP_MARKER" "$(template_starship_bashrc)"
  else
    echo "$(yellow "⚠") $bashrc does not exist — skipping bash"
  fi
fi

# ===================================================================
# Summary
# ===================================================================
echo ""
echo "$(green_bold "━━━ Configuration complete ━━━")"
echo ""
echo "Next steps:"
echo "  1. Reload shell:        $(bold "exec \$SHELL")"
echo "  2. Edit config:         $(bold "vim $config_file")"
echo "  3. Browse presets:      $(bold "starship preset list")"
echo "  4. Apply preset later:  $(bold "starship preset tokyo-night -o $config_file")"
echo "  5. Docs:                $(bold "https://starship.rs/config/")"
