skip_shell=${args[--skip-shell]}

name="zoxide"
echo "Configuring $(cyan_bold "$name")..."
echo ""

require_installed "$name" "$(command -v "$name" 2>/dev/null)"
echo "$(green_bold "✓") $name found at $(command -v "$name")"

if [ -n "$skip_shell" ]; then
  echo "$(yellow "⚠") Skipping shell init (--skip-shell)"
else
  echo ""
  setup_shell_tool "$name" \
    "# --- zoxide init (managed by os-scripts) ---" \
    "$(template_zoxide_zshrc)" \
    "$(template_zoxide_bashrc)"
fi

echo ""
echo "$(green_bold "✓") $name configured. Reload your shell: $(bold "exec \$SHELL")"
echo "  Tip: jump to a recent dir with $(bold "z <pattern>") or $(bold "zi") for interactive picker."
