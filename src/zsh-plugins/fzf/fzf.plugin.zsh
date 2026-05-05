# fzf zsh integration
(( $+commands[fzf] )) || return 0
if fzf --zsh >/dev/null 2>&1; then
  local cache="$HOME/.cache/gt/fzf.zsh"
  [[ "$commands[fzf]" -nt "$cache" ]] && { mkdir -p "${cache:h}"; fzf --zsh >| "$cache" }
  source "$cache"
elif [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
fi
