skip_plugins=${args[--skip-plugins]}
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
elif grep -qF "$ANTIDOTE_MARKER" "$zshrc" 2>/dev/null; then
  echo "$(yellow "⚠") antidote bootstrap block already exists in $zshrc — skipping"
else
  # Create .zshrc if it doesn't exist
  [ -f "$zshrc" ] || touch "$zshrc"

  # Append the bootstrap block
  {
    echo ""
    echo "$ANTIDOTE_MARKER"
    echo "# Source antidote"
    echo 'if [[ -f /usr/local/share/antidote/antidote.zsh ]]; then'
    echo '  source /usr/local/share/antidote/antidote.zsh'
    echo 'elif [[ -f ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh ]]; then'
    echo '  source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh'
    echo 'fi'
    echo ''
    echo '# Static plugin loading (fast)'
    echo 'zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins.txt'
    echo '[[ -f $zsh_plugins ]] || touch $zsh_plugins'
    echo 'if [[ ! ${zsh_plugins}.zsh -nt $zsh_plugins ]]; then'
    echo '  antidote bundle <$zsh_plugins >${zsh_plugins}.zsh'
    echo 'fi'
    echo 'source ${zsh_plugins}.zsh'
    echo 'unset zsh_plugins'
    echo "# --- end antidote bootstrap ---"
  } >> "$zshrc"
  echo "$(green_bold "✓") antidote bootstrap added to $zshrc"
fi

# ===================================================================
# Step 3: Seed ~/.zsh_plugins.txt
# ===================================================================
echo ""
echo "$(bold "▸ Step 3/3:") Seeding $(cyan "$zsh_plugins_file")..."

if [ -n "$skip_plugins" ]; then
  echo "$(yellow "⚠") Skipping plugin seeding (--skip-plugins)"
elif [ -s "$zsh_plugins_file" ]; then
  echo "$(yellow "⚠") $zsh_plugins_file already has content — skipping (delete it first to re-seed)"
else
  {
    echo "# === Completion & syntax ==="
    echo "zsh-users/zsh-completions"
    echo "zsh-users/zsh-autosuggestions"
    echo "zsh-users/zsh-syntax-highlighting"
    echo "zsh-users/zsh-history-substring-search"
    echo ""
    echo "# === Oh-My-Zsh libs (selective) ==="
    echo "ohmyzsh/ohmyzsh path:lib/clipboard.zsh"
    echo "ohmyzsh/ohmyzsh path:lib/history.zsh"
    echo "ohmyzsh/ohmyzsh path:lib/key-bindings.zsh"
    echo ""
    echo "# === DevOps plugins ==="
    echo "ohmyzsh/ohmyzsh path:plugins/git"
    echo "ohmyzsh/ohmyzsh path:plugins/kubectl"
    echo "ohmyzsh/ohmyzsh path:plugins/docker"
    echo "ohmyzsh/ohmyzsh path:plugins/helm"
    echo "ohmyzsh/ohmyzsh path:plugins/terraform"
    echo ""
    echo "# === Tools ==="
    echo "ajeetdsouza/zoxide"
    echo "Aloxaf/fzf-tab"
  } > "$zsh_plugins_file"
  echo "$(green_bold "✓") Seeded $zsh_plugins_file with recommended DevOps plugins"
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
