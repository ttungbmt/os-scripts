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

# NOTE: per-tool shell init (starship, zoxide, mcfly, fzf, direnv, thefuck …)
# is owned by `gt setup <tool>` — each writes its own marker block in this rc
# file so the plugin manager stays decoupled from individual tool integrations.
# --- end antidote bootstrap ---
EOF
}

# Returns the default curated list of Zsh plugins for ~/.zsh_plugins.txt.
#
# Architecture: zephyr (foundation) + OMZ (tool-specific only) + curated extras.
# zephyr is the antidote author's own modular replacement for OMZ libs — faster
# startup, no legacy cruft. We still pull in OMZ for plugins zephyr intentionally
# omits (docker, git aliases, sudo widget, extract, command-not-found …).
#
# Order is significant — DO NOT reorder without understanding why:
#   1. fpath-only plugins (zsh-completions) BEFORE any plugin that runs compinit
#   2. zephyr foundation modules before zephyr's `completion` module
#   3. zephyr/completion runs compinit, so it must come before fzf-tab
#   4. zsh-vi-mode AFTER zephyr/editor so its bindings win
#   5. fzf-tab AFTER compinit but BEFORE plugins that wrap the Tab widget
#      (autosuggestions, fast-syntax-highlighting)
#   6. fast-syntax-highlighting BEFORE zsh-history-substring-search
#   7. getantidote/use-omz required for OMZ subplugins that depend on OMZ libs
template_antidote_plugins() {
  local gt_repo="$1"
  cat <<EOF
# ─── Completions library (fpath only — must precede any compinit) ───
zsh-users/zsh-completions path:src kind:fpath

# ─── Zephyr foundation (modular replacement for OMZ libs / supercharge) ───
mattmc3/zephyr path:plugins/environment
mattmc3/zephyr path:plugins/editor
mattmc3/zephyr path:plugins/history
mattmc3/zephyr path:plugins/directory
mattmc3/zephyr path:plugins/utility
mattmc3/zephyr path:plugins/completion

# ─── Vi mode (after zephyr/editor so its bindings win; zvm_after_init re-binds) ───
jeffreytse/zsh-vi-mode

# ─── fzf-powered tab completion (after compinit, before widget wrappers) ───
Aloxaf/fzf-tab

# ─── Editing ergonomics ───
hlissner/zsh-autopair
olets/zsh-abbr

# ─── Oh-my-zsh atomic plugins (use-omz wires up OMZ runtime libs) ───
getantidote/use-omz
ohmyzsh/ohmyzsh path:plugins/extract
ohmyzsh/ohmyzsh path:plugins/sudo
ohmyzsh/ohmyzsh path:plugins/colored-man-pages
ohmyzsh/ohmyzsh path:plugins/command-not-found
ohmyzsh/ohmyzsh path:plugins/git
ohmyzsh/ohmyzsh path:plugins/docker
ohmyzsh/ohmyzsh path:plugins/docker-compose

# ─── fzf + git workflow (gd, glo, gss, gcf, ga, gi …) ───
wfxr/forgit

# ─── Reminds you of existing aliases / functions ───
MichaelAquilina/zsh-you-should-use

# ─── Autosuggestions (fish-style, must be before syntax highlighting) ───
zsh-users/zsh-autosuggestions

# ─── Syntax highlighting (must be before history-substring-search) ───
zdharma-continuum/fast-syntax-highlighting

# ─── History search (MUST be the last widget-binding plugin) ───
zsh-users/zsh-history-substring-search

# ─── OS Scripts Local Integrations (Cached Shell Init) ───
$gt_repo/src/zsh-plugins/zoxide
$gt_repo/src/zsh-plugins/mcfly
$gt_repo/src/zsh-plugins/fzf
$gt_repo/src/zsh-plugins/direnv
$gt_repo/src/zsh-plugins/thefuck
$gt_repo/src/zsh-plugins/starship
EOF
}
