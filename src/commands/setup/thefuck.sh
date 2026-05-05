skip_shell=${args[--skip-shell]}

name="thefuck"
echo "Configuring $(cyan_bold "$name")..."
echo ""

require_installed "$name" "$(command -v "$name" 2>/dev/null)"
echo "$(green_bold "✓") $name found at $(command -v "$name")"

if [ -n "$skip_shell" ]; then
  echo "$(yellow "⚠") Skipping shell init (--skip-shell)"
else
  echo ""
  setup_shell_tool "$name" \
    "# --- thefuck alias (managed by os-scripts) ---" \
    "$(template_thefuck_zshrc)" \
    "$(template_thefuck_bashrc)"
fi

echo ""
echo "$(green_bold "✓") $name configured. Reload your shell: $(bold "exec \$SHELL")"
echo "  Tip: type $(bold "fuck") after a failed command to get a correction suggestion."
