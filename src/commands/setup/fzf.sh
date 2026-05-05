skip_shell=${args[--skip-shell]}

name="fzf"
echo "Configuring $(cyan_bold "$name")..."
echo ""

require_installed "$name" "$(command -v "$name" 2>/dev/null)"
fzf_version=$(fzf --version 2>/dev/null | awk '{print $1}')
echo "$(green_bold "✓") $name found at $(command -v "$name") (v${fzf_version:-unknown})"

if [ -n "$skip_shell" ]; then
  echo "$(yellow "⚠") Skipping shell init (--skip-shell)"
else
  echo ""
  setup_shell_tool "$name" \
    "# --- fzf init (managed by os-scripts) ---" \
    "$(template_fzf_zshrc)" \
    "$(template_fzf_bashrc)"

  if ! fzf --zsh >/dev/null 2>&1; then
    echo ""
    echo "$(yellow "⚠") fzf < v0.48 — falling back to ~/.fzf.{zsh,bash}."
    echo "  Run $(bold "$(dirname "$(command -v fzf)")/../share/fzf/install --all") if those files don't exist."
  fi
fi

echo ""
echo "$(green_bold "✓") $name configured. Reload your shell: $(bold "exec \$SHELL")"
echo "  Tip: $(bold "Ctrl-R") fuzzy history, $(bold "Ctrl-T") fuzzy file picker, $(bold "Alt-C") fuzzy cd."
