force=${args[--force]}
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
  # Check if the tool exists in our registry
  registry_file="src/lib/registry/${tool}.sh"
  
  if [ -f "$registry_file" ] || declare -F "gc_install_${tool}_command" > /dev/null; then
    echo "==========================================="
    echo "Installing: $(cyan_bold "$tool")"
    echo "==========================================="
    
    # We call the internal bashly generated command function for that tool if it exists
    if declare -F "gc_install_${tool}_command" > /dev/null; then
      # Setup arguments exactly as the command expects
      # We clear existing args first
      local orig_args
      orig_args=$(declare -p args)
      
      # Prepare args for the specific tool command
      args['--version']="latest"
      if [[ -n "$force" ]]; then
        args['--force']=1
      fi
      
      # Call the internal function in a subshell to prevent 'exit' from killing the loop
      ( gc_install_${tool}_command ) || true
      
      # Restore args
      eval "$orig_args"
    else
      # Fallback to generic if command function doesn't exist but registry does
      export TARGET_TOOL="$tool"
      ( run_generic_install "$tool" "latest" "$force" ) || true
    fi
    echo ""
  else
    echo "$(red "Error:") Tool '$(cyan_bold "$tool")' is not supported or not found."
    echo ""
  fi
done
