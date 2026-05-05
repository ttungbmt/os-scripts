skip_shell=${args[--skip-shell]}

name="mcfly"
echo "Configuring $(cyan_bold "$name")..."
echo ""

require_installed "$name" "$(command -v "$name" 2>/dev/null)"
echo "$(green_bold "✓") $name found at $(command -v "$name")"

if [ -n "$skip_shell" ]; then
  echo "$(yellow "⚠") Skipping shell init (--skip-shell)"
else
  echo ""
  setup_shell_tool "$name" \
    "# --- mcfly init (managed by os-scripts) ---" \
    "$(template_mcfly_zshrc)" \
    "$(template_mcfly_bashrc)"
fi

echo ""
echo "$(green_bold "✓") $name configured. Reload your shell: $(bold "exec \$SHELL")"
echo "  Tip: $(bold "Ctrl-R") opens fuzzy history search; set $(bold "MCFLY_FUZZY=2") in your rc for fuzzy match."
