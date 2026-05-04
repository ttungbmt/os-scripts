## Antidote setup templates
## This file is located in 'src/lib/templates/antidote.sh'

# Returns the bootstrap block to be injected into ~/.zshrc
template_antidote_zshrc() {
  cat <<'EOF'
# --- antidote bootstrap (managed by os-scripts) ---
# Source antidote
if [[ -f /usr/local/share/antidote/antidote.zsh ]]; then
  source /usr/local/share/antidote/antidote.zsh
elif [[ -f ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh ]]; then
  source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh
fi

# Static plugin loading (fast)
zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins.txt
[[ -f $zsh_plugins ]] || touch $zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt $zsh_plugins ]]; then
  antidote bundle <$zsh_plugins >${zsh_plugins}.zsh
fi
source ${zsh_plugins}.zsh
unset zsh_plugins

# Initialize zoxide if installed
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# Initialize fzf if installed
if (( $+commands[fzf] )); then
  eval "$(fzf --zsh)"
fi

# Initialize direnv if installed
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# Initialize thefuck if installed
if (( $+commands[thefuck] )); then
  eval "$(thefuck --alias)"
fi

# Initialize mcfly (smart history) if installed
if (( $+commands[mcfly] )); then
  eval "$(mcfly init zsh)"
fi

# Initialize starship prompt if installed
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi
# --- end antidote bootstrap ---
EOF
}

# Returns the default curated list of Zsh plugins for ~/.zsh_plugins.txt
template_antidote_plugins() {
  cat <<'EOF'
jeffreytse/zsh-vi-mode
olets/zsh-abbr

MichaelAquilina/zsh-you-should-use

zsh-users/zsh-completions
zsh-users/zsh-autosuggestions
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-history-substring-search
zdharma-continuum/history-search-multi-word
zdharma-continuum/fast-syntax-highlighting
zap-zsh/supercharge
EOF
}
