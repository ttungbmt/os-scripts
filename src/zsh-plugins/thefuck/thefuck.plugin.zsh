# thefuck zsh integration
(( $+commands[thefuck] )) || return 0
local cache="$HOME/.cache/gt/thefuck.zsh"
[[ "$commands[thefuck]" -nt "$cache" ]] && { mkdir -p "${cache:h}"; thefuck --alias >| "$cache" }
source "$cache"
