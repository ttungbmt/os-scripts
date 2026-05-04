# Generic installer engine
# Centralizes download and extraction logic for all tools

run_generic_install() {
  local name="$1"
  local version="$2"
  local force="$3"
  local target="/usr/local/bin/$name"

  # Load tool configurations from its registry namespace
  local tool_upper
  tool_upper=$(echo "$name" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  
  local install_type_var="${tool_upper}_INSTALL_TYPE"
  local install_type="${!install_type_var:-github_release}"
  
  local repo_var="${tool_upper}_GITHUB_REPO"
  local repo="${!repo_var}"
  
  local archive_var="${tool_upper}_ARCHIVE_TYPE"
  local archive_type="${!archive_var:-binary}"
  
  local pattern_var="${tool_upper}_ASSET_PATTERN"
  local asset_pattern="${!pattern_var}"

  # Step 1: Guard against overwrite
  guard_existing "$name" "$target" "$force"

  echo "Installing $(cyan_bold "$name") ($(yellow "$version"))..."

  if [[ "$install_type" == "github_release" ]]; then
    if [[ -z "$repo" ]]; then
      echo "$(red "Error: GitHub repo not defined for $name")"
      exit 1
    fi

    # Step 2: Resolve version
    if [[ "$version" == "latest" ]]; then
      if type "${name}_fetch_remote_version" &>/dev/null; then
        version=$("${name}_fetch_remote_version")
      else
        version=$(github_latest_tag "$repo")
      fi
    fi

    local dl_version="$version"
    if [[ "$dl_version" == v* ]]; then
      dl_version="${dl_version:1}"
    fi

    # Step 3: Detect platform
    detect_platform

    # Custom architecture mappings for some tools (e.g. some use x86_64 instead of amd64)
    local arch_mapped="$DETECT_ARCH"
    local arch_map_var="${tool_upper}_ARCH_MAP_${DETECT_ARCH}"
    local arch_map_val="${!arch_map_var}"
    if [[ -n "$arch_map_val" ]]; then
      arch_mapped="$arch_map_val"
    fi

    local os_mapped="$DETECT_OS"
    local os_map_var="${tool_upper}_OS_MAP_${DETECT_OS}"
    local os_map_val="${!os_map_var}"
    if [[ -n "$os_map_val" ]]; then
      os_mapped="$os_map_val"
    fi

    local asset_name="$asset_pattern"
    asset_name="${asset_name//\$\{DETECT_OS\}/$os_mapped}"
    asset_name="${asset_name//\$\{DETECT_ARCH\}/$arch_mapped}"
    asset_name="${asset_name//\$\{VERSION\}/$dl_version}"
    asset_name="${asset_name//\$\{V_VERSION\}/v$dl_version}"

    # Determine tag for download URL
    local tag_prefix_var="${tool_upper}_TAG_PREFIX"
    local tag_prefix="${!tag_prefix_var-v}"
    
    # If the tag from API already includes the prefix, don't duplicate it. 
    # But since github_latest_tag returns exact tag, if user provided 'latest', it is exact.
    # If user provided version manually (e.g. 1.2.3), we might need to add prefix.
    local download_tag="$version"
    if [[ "$version" != "latest" && "$version" != v* && -n "$tag_prefix" ]]; then
       download_tag="${tag_prefix}${version}"
    fi

    local download_url="https://github.com/${repo}/releases/download/${download_tag}/${asset_name}"
    
    local url_var="${tool_upper}_DOWNLOAD_URL"
    local custom_url="${!url_var}"
    if [[ -n "$custom_url" ]]; then
        download_url="$custom_url"
        download_url="${download_url//\$\{DETECT_OS\}/$os_mapped}"
        download_url="${download_url//\$\{DETECT_ARCH\}/$arch_mapped}"
        download_url="${download_url//\$\{VERSION\}/$dl_version}"
        download_url="${download_url//\$\{V_VERSION\}/v$dl_version}"
        download_url="${download_url//\$\{TAG\}/$download_tag}"
    fi

    # Step 4: Download
    local temp_dir
    temp_dir=$(mktemp -d)
    
    if [[ "$archive_type" == "binary" ]]; then
      download_file "$download_url" "$temp_dir/$name"
      install_binary "$temp_dir/$name" "$target"
    elif [[ "$archive_type" == "tar.gz" ]]; then
      download_file "$download_url" "$temp_dir/archive.tar.gz"
      tar -xzf "$temp_dir/archive.tar.gz" -C "$temp_dir"
      
      local bin_path_var="${tool_upper}_BIN_PATH"
      local bin_path="${!bin_path_var:-$name}"
      
      if [[ -f "$temp_dir/$bin_path" ]]; then
        install_binary "$temp_dir/$bin_path" "$target"
      else
         local found
         found=$(find "$temp_dir" -type f -name "$name" | head -n 1)
         if [[ -n "$found" ]]; then
            install_binary "$found" "$target"
         else
            echo "$(red "Could not find binary $name in archive")"
            ls -la "$temp_dir"
            rm -rf "$temp_dir"
            exit 1
         fi
      fi
    elif [[ "$archive_type" == "zip" ]]; then
      download_file "$download_url" "$temp_dir/archive.zip"
      unzip -q "$temp_dir/archive.zip" -d "$temp_dir"
      
      local bin_path_var="${tool_upper}_BIN_PATH"
      local bin_path="${!bin_path_var:-$name}"
      
      if [[ -f "$temp_dir/$bin_path" ]]; then
        install_binary "$temp_dir/$bin_path" "$target"
      else
         local found
         found=$(find "$temp_dir" -type f -name "$name" | head -n 1)
         if [[ -n "$found" ]]; then
            install_binary "$found" "$target"
         else
            echo "$(red "Could not find binary $name in archive")"
            rm -rf "$temp_dir"
            exit 1
         fi
      fi
    fi
    rm -rf "$temp_dir"
    echo "$(green_bold ✓) $name installed successfully: $(bold "v${dl_version}")"
    
  elif [[ "$install_type" == "pip" ]]; then
     local pip_pkg_var="${tool_upper}_PIP_PKG"
     local pip_pkg="${!pip_pkg_var:-$name}"
     
     if [[ "$version" != "latest" ]]; then
        local dl_version="$version"
        if [[ "$dl_version" == v* ]]; then
          dl_version="${dl_version:1}"
        fi
        pip_pkg="$pip_pkg==$dl_version"
     fi
     
     if ! command -v pip3 >/dev/null 2>&1; then
       echo "$(red "Error: pip3 is not installed. Please install python3-pip first.")"
       exit 1
     fi
     
     echo "Running pip3 install..."
     if sudo pip3 install --upgrade "$pip_pkg"; then
       echo "$(green_bold ✓) $name installed successfully!"
     else
       echo "$(red ✗ Failed to install $name.)"
       exit 1
     fi
  fi
}
