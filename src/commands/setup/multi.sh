skip_shell=${args[--skip-shell]}
eval "raw_tools=(${args['tools']})"

# Process both space-separated and comma-separated inputs
tools=()
for t in "${raw_tools[@]}"; do
  IFS=',' read -ra split_tools <<< "$t"
  for st in "${split_tools[@]}"; do
    if [[ -n "$st" ]]; then
      tools+=("$st")
    fi
  done
done

for tool in "${tools[@]}"; do
  # We call the internal bashly generated command function for that tool if it exists
  if declare -F "gc_setup_${tool}_command" > /dev/null; then
    echo "==========================================="
    echo "Configuring: $(cyan_bold "$tool")"
    echo "==========================================="
    
    # We clear existing args first
    local orig_args
    orig_args=$(declare -p args)
    
    # Prepare args for the specific tool command
    if [[ -n "$skip_shell" ]]; then
      args['--skip-shell']=1
    fi
    
    # Call the internal function in a subshell to prevent 'exit' from killing the loop
    ( gc_setup_${tool}_command ) || true
    
    # Restore args
    eval "$orig_args"
    echo ""
  else
    echo "$(red "Error:") Tool '$(cyan_bold "$tool")' does not have a setup command or is not found."
    echo ""
  fi
done
