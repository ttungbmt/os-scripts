all=${args[--all]}
target_tool=${args[tool]}

# Dynamically get the list of available tools from the help menu
available_tools=()
while read -r tool; do
  if [[ -n "$tool" && "$tool" != "multi" ]]; then
    available_tools+=("$tool")
  fi
done < <("$0" install --help | awk '/^  [a-z0-9A-Z]/{print $1}')

if [ -n "$target_tool" ]; then
  tools=("$target_tool")
  all=1 # Force check even if not installed
else
  tools=("${available_tools[@]}")
fi

echo "Checking for updates..."
echo ""

for tool in "${tools[@]}"; do
  local_ver=$(get_local_version "$tool")
  
  if [ -z "$local_ver" ]; then
    if [ -n "$all" ]; then
      printf "  %-12s %s\n" "$tool" "[Not installed]"
    fi
    continue
  fi
  
  remote_ver=$(get_remote_version "$tool")
  
  if [ -z "$remote_ver" ]; then
    printf "  %-12s %s\n" "$tool" "$(yellow "Error fetching remote version")"
    continue
  fi
  
  if [ "$local_ver" == "$remote_ver" ]; then
    printf "$(green_bold "[Up-to-date]") %-12s (v%s)\n" "$tool" "$local_ver"
  else
    printf "$(red_bold "[Outdated]")   %-12s v%s -> v%s\n" "$tool" "$local_ver" "$remote_ver"
  fi
done
echo ""
