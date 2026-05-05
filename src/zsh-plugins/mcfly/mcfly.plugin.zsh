# mcfly zsh integration
(( $+commands[mcfly] )) || return 0
local cache="$HOME/.cache/gt/mcfly.zsh"
[[ ! -f "$cache" || "$commands[mcfly]" -nt "$cache" ]] && { mkdir -p "${cache:h}"; mcfly init zsh >| "$cache" }
source "$cache"
