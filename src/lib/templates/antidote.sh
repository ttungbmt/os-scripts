## Antidote setup templates
## This file is located in 'src/lib/templates/antidote.sh'

# Returns the bootstrap block to be injected into ~/.zshrc
template_antidote_zshrc() {
  cat <<'EOF'
# --- antidote bootstrap (managed by os-scripts) ---
for _antidote_path in \
  /opt/homebrew/opt/antidote/share/antidote/antidote.zsh \
  /usr/local/opt/antidote/share/antidote/antidote.zsh \
  /usr/local/share/antidote/antidote.zsh \
  ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh; do
  [[ -f $_antidote_path ]] && { source "$_antidote_path"; break; }
done
unset _antidote_path

# zsh-vi-mode defers init to first prompt and overwrites earlier bindkeys.
# Re-bind autosuggestions / history-substring-search inside its post-init hook.
function zvm_after_init() {
  bindkey '^[[A' history-substring-search-up    2>/dev/null
  bindkey '^[[B' history-substring-search-down  2>/dev/null
  bindkey '^P'   history-substring-search-up    2>/dev/null
  bindkey '^N'   history-substring-search-down  2>/dev/null
  bindkey '^ '   autosuggest-accept             2>/dev/null
}

# Static plugin loading — recompile bundle when source list changes
zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins.txt
[[ -f $zsh_plugins ]] || touch $zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt $zsh_plugins ]]; then
  antidote bundle <$zsh_plugins >${zsh_plugins}.zsh
fi
source ${zsh_plugins}.zsh
unset zsh_plugins

# Remove omz git plugin's gc alias so it doesn't conflict with our own gc command
unalias gc 2>/dev/null || true

# NOTE: per-tool shell init (starship, zoxide, mcfly, fzf, direnv, thefuck …)
# is owned by `gt setup <tool>` — each writes its own marker block in this rc
# file so the plugin manager stays decoupled from individual tool integrations.
# --- end antidote bootstrap ---
EOF
}

# Returns the default curated list of Zsh plugins for ~/.zsh_plugins.txt.
#
# Architecture: 7-phase load order (DO NOT reorder without understanding each phase).
#
# Phase 1 — fpath augmentation   : zsh-completions (kind:fpath, before compinit)
# Phase 2 — Shell foundation     : zephyr modules; /completion fires compinit last
# Phase 3 — Widget layer         : vi-mode → fzf-tab → ZLE ergonomics (post-compinit)
# Phase 4 — OMZ plugins          : use-omz first, then alias/completion plugins
# Phase 5 — Alias-aware extras   : forgit, you-should-use (after OMZ aliases exist)
# Phase 6 — Completion UI + hist : autosuggestions → fast-syntax-highlight → hist-search
# Phase 7 — Local integrations   : os-scripts cached inits (mcfly …)
#
# Key constraints:
#   • zsh-vi-mode re-initialises the line editor — must come before fzf-tab / ZLE plugins
#   • fzf-tab hooks Tab before any other plugin wraps it (after compinit)
#   • fast-syntax-highlighting must precede zsh-history-substring-search
#   • zsh-history-substring-search MUST be the last widget-binding plugin
#   • getantidote/use-omz required for all OMZ subplugins that depend on OMZ libs
template_antidote_plugins() {
  cat <<EOF
# ══ Phase 1 — fpath augmentation (before compinit) ═══════════════════════════
zsh-users/zsh-completions path:src kind:fpath

# ══ Phase 2 — Shell foundation ═══════════════════════════════════════════════
# zephyr: modular replacement for OMZ libs — faster startup, no legacy cruft.
# /completion is last because it calls compinit.
mattmc3/zephyr path:plugins/environment
mattmc3/zephyr path:plugins/editor
mattmc3/zephyr path:plugins/history
mattmc3/zephyr path:plugins/directory
mattmc3/zephyr path:plugins/utility
mattmc3/zephyr path:plugins/completion

# ══ Phase 3 — Widget layer (post-compinit; strict order within phase) ════════
# vi-mode re-initialises the line editor — must win over zephyr/editor bindings.
# zvm_after_init() in .zshrc re-binds autosuggestions + history-search after it.
jeffreytse/zsh-vi-mode

# fzf-tab hooks Tab widget before any other plugin can wrap it.
Aloxaf/fzf-tab

# ZLE ergonomics — initialised after compinit and vi-mode.
hlissner/zsh-autopair
olets/zsh-abbr

# ══ Phase 4 — OMZ plugins (order-agnostic within groups) ═════════════════════
getantidote/use-omz

# Shell utility
ohmyzsh/ohmyzsh path:plugins/extract
ohmyzsh/ohmyzsh path:plugins/sudo
ohmyzsh/ohmyzsh path:plugins/colored-man-pages
ohmyzsh/ohmyzsh path:plugins/command-not-found
ohmyzsh/ohmyzsh path:plugins/profiles

# Remote / terminal
ohmyzsh/ohmyzsh path:plugins/ssh
ohmyzsh/ohmyzsh path:plugins/mosh
ohmyzsh/ohmyzsh path:plugins/tmux conditional:"command -v tmux >/dev/null"

# SCM
ohmyzsh/ohmyzsh path:plugins/git
ohmyzsh/ohmyzsh path:plugins/gh

# Containers / orchestration
ohmyzsh/ohmyzsh path:plugins/docker
ohmyzsh/ohmyzsh path:plugins/docker-compose
ohmyzsh/ohmyzsh path:plugins/kubectl
ohmyzsh/ohmyzsh path:plugins/kubectx
ohmyzsh/ohmyzsh path:plugins/k9s
ohmyzsh/ohmyzsh path:plugins/vagrant

# Languages / runtimes
ohmyzsh/ohmyzsh path:plugins/python
ohmyzsh/ohmyzsh path:plugins/dbt
ohmyzsh/ohmyzsh path:plugins/ansible
ohmyzsh/ohmyzsh path:plugins/mise

# Navigation / environment
ohmyzsh/ohmyzsh path:plugins/direnv
ohmyzsh/ohmyzsh path:plugins/fzf
ohmyzsh/ohmyzsh path:plugins/eza
ohmyzsh/ohmyzsh path:plugins/zoxide

# Shell tools / dotfile management
ohmyzsh/ohmyzsh path:plugins/thefuck conditional:"command -v thefuck >/dev/null"
ohmyzsh/ohmyzsh path:plugins/chezmoi
ohmyzsh/ohmyzsh path:plugins/tailscale
ohmyzsh/ohmyzsh path:plugins/starship

# ══ Phase 5 — Alias-aware extras (after OMZ defines aliases) ═════════════════
wfxr/forgit                              # fzf + git workflow (gd, glo, gss …)
MichaelAquilina/zsh-you-should-use       # nudges you toward existing aliases

# ══ Phase 6 — Completion UI + history (strict order) ═════════════════════════
zsh-users/zsh-autosuggestions            # fish-style; before syntax highlighting
zdharma-continuum/fast-syntax-highlighting  # before history-substring-search
zsh-users/zsh-history-substring-search      # MUST be last widget-binding plugin

# ══ Phase 7 — Local integrations ═════════════════════════════════════════════
ttungbmt/os-scripts path:plugins/zsh-mcfly
EOF
}
