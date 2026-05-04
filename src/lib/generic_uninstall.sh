run_generic_uninstall() {
  local name="$1"
  local target="/usr/local/bin/$name"

  local tool_upper
  tool_upper=$(echo "$name" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  
  local install_type_var="${tool_upper}_INSTALL_TYPE"
  local install_type="${!install_type_var:-github_release}"
  
  if [[ "$install_type" == "pip" ]]; then
      local pip_target
      pip_target=$(command -v "$name")
      
      if [ -z "$pip_target" ]; then
        echo "$(cyan_bold "$name") is not installed."
        exit 0
      fi

      echo "Uninstalling $(cyan_bold "$name")..."
      if sudo pip3 uninstall -y "$name"; then
        echo "$(green_bold ✓) $name uninstalled successfully."
      else
        echo "$(red ✗ Failed to uninstall $name.)"
        exit 1
      fi
  else
      # Standard binary uninstall
      uninstall_tool "$name" "$target"
  fi
}
