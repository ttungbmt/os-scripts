## Shell-init templates for standalone CLI tools
## This file is located in 'src/lib/templates/shell_tools.sh'
##
## Convention: each tool exposes `template_<tool>_zshrc` and `template_<tool>_bashrc`.
## Each block uses a stable marker so injection is idempotent.

# ─────────────────────────────────────────────────────────── zoxide
template_zoxide_zshrc() {
  cat <<'EOF'
# --- zoxide init (managed by os-scripts) ---
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi
# --- end zoxide init ---
EOF
}

template_zoxide_bashrc() {
  cat <<'EOF'
# --- zoxide init (managed by os-scripts) ---
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi
# --- end zoxide init ---
EOF
}

# ─────────────────────────────────────────────────────────── mcfly
template_mcfly_zshrc() {
  cat <<'EOF'
# --- mcfly init (managed by os-scripts) ---
if (( $+commands[mcfly] )); then
  eval "$(mcfly init zsh)"
fi
# --- end mcfly init ---
EOF
}

template_mcfly_bashrc() {
  cat <<'EOF'
# --- mcfly init (managed by os-scripts) ---
if command -v mcfly >/dev/null 2>&1; then
  eval "$(mcfly init bash)"
fi
# --- end mcfly init ---
EOF
}

# ─────────────────────────────────────────────────────────── direnv
template_direnv_zshrc() {
  cat <<'EOF'
# --- direnv hook (managed by os-scripts) ---
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi
# --- end direnv hook ---
EOF
}

template_direnv_bashrc() {
  cat <<'EOF'
# --- direnv hook (managed by os-scripts) ---
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi
# --- end direnv hook ---
EOF
}

# ─────────────────────────────────────────────────────────── thefuck
template_thefuck_zshrc() {
  cat <<'EOF'
# --- thefuck alias (managed by os-scripts) ---
if (( $+commands[thefuck] )); then
  eval "$(thefuck --alias)"
fi
# --- end thefuck alias ---
EOF
}

template_thefuck_bashrc() {
  cat <<'EOF'
# --- thefuck alias (managed by os-scripts) ---
if command -v thefuck >/dev/null 2>&1; then
  eval "$(thefuck --alias)"
fi
# --- end thefuck alias ---
EOF
}

# ─────────────────────────────────────────────────────────── fzf
# fzf >= v0.48 ships built-in shell integration via `fzf --zsh|--bash`.
# Older versions write ~/.fzf.{zsh,bash} during install — fall back to those.
template_fzf_zshrc() {
  cat <<'EOF'
# --- fzf init (managed by os-scripts) ---
if (( $+commands[fzf] )); then
  if fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  elif [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
  fi
fi
# --- end fzf init ---
EOF
}

template_fzf_bashrc() {
  cat <<'EOF'
# --- fzf init (managed by os-scripts) ---
if command -v fzf >/dev/null 2>&1; then
  if fzf --bash >/dev/null 2>&1; then
    eval "$(fzf --bash)"
  elif [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
  fi
fi
# --- end fzf init ---
EOF
}
