# direnv zsh integration
(( $+commands[direnv] )) || return 0
local cache="$HOME/.cache/gt/direnv.zsh"
[[ "$commands[direnv]" -nt "$cache" ]] && { mkdir -p "${cache:h}"; direnv hook zsh >| "$cache" }
source "$cache"
