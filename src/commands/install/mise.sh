export TARGET_TOOL="mise"
run_generic_install "mise" "${args[--version]}" "${args[--force]}"

# Automatically configure shell profiles for mise
marker="# mise tools"
zsh_block='eval "$(mise activate zsh)"'
bash_block='eval "$(mise activate bash)"'
setup_shell_tool "mise" "$marker" "$zsh_block" "$bash_block"
