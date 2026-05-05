# starship zsh integration
(( $+commands[starship] )) || return 0
local cache="$HOME/.cache/gt/starship.zsh"
[[ ! -f "$cache" || "$commands[starship]" -nt "$cache" ]] && { mkdir -p "${cache:h}"; starship init zsh >| "$cache" }
source "$cache"
