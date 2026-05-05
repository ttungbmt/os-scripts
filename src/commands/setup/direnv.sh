skip_shell=${args[--skip-shell]}

name="direnv"
echo "Configuring $(cyan_bold "$name")..."
echo ""

require_installed "$name" "$(command -v "$name" 2>/dev/null)"
echo "$(green_bold "✓") $name found at $(command -v "$name")"

if [ -n "$skip_shell" ]; then
  echo "$(yellow "⚠") Skipping shell init (--skip-shell)"
else
  echo ""
  setup_shell_tool "$name" \
    "# --- direnv hook (managed by os-scripts) ---" \
    "$(template_direnv_zshrc)" \
    "$(template_direnv_bashrc)"
fi

echo ""
echo "$(green_bold "✓") $name configured. Reload your shell: $(bold "exec \$SHELL")"
echo "  Tip: drop a $(bold ".envrc") in any project, then $(bold "direnv allow") to activate."
