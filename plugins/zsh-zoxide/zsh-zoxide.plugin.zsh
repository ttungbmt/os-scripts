# zoxide zsh integration
(( $+commands[zoxide] )) || return 0
local cache="$HOME/.cache/gt/zoxide.zsh"
[[ ! -f "$cache" || "$commands[zoxide]" -nt "$cache" ]] && { mkdir -p "${cache:h}"; zoxide init zsh >| "$cache" }
source "$cache"
