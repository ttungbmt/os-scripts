#!/usr/bin/env python3
import os
import sys
import re

def main():
    if len(sys.argv) < 2:
        print("Usage: scaffold.py tool1 tool2 ...")
        sys.exit(1)

    tools = sys.argv[1:]
    bashly_path = "src/bashly.yml"
    with open(bashly_path, "r") as f:
        content = f.read()

    for tool in tools:
        if f"- name: {tool}" in content:
            print(f"Tool {tool} already in bashly.yml")
            continue
            
        print(f"Adding {tool}")
        
        # We need to insert under install -> commands and uninstall -> commands
        # The easiest way without a parser is to find where the uninstall command starts,
        # insert right before it for install.
        # And insert at the end of uninstall block for uninstall.
        
        install_block = f"""
  - name: {tool}
    help: Install {tool}
    flags:
    - long: --version
      short: -v
      arg: version
      help: {tool} version to install (e.g., v1.0.0 or latest)
      default: latest
    - long: --force
      short: -f
      help: Force overwrite if {tool} is already installed
"""
        uninstall_block = f"""
  - name: {tool}
    help: Uninstall {tool}
"""

        # find the line '- name: uninstall'
        uninstall_idx = content.find("- name: uninstall")
        if uninstall_idx == -1:
            print("Cannot find uninstall block")
            break
            
        content = content[:uninstall_idx] + install_block.lstrip('\n') + content[uninstall_idx:]
        
        # find the line '- name: outdated'
        outdated_idx = content.find("- name: outdated")
        if outdated_idx == -1:
            print("Cannot find outdated block")
            break
            
        content = content[:outdated_idx] + uninstall_block.lstrip('\n') + content[outdated_idx:]
        
        # Create install script
        install_script_path = f"src/commands/install/{tool}.sh"
        with open(install_script_path, "w") as f:
            f.write(f'export TARGET_TOOL="{tool}"\n')
            f.write(f'run_generic_install "{tool}" "${{args[--version]}}" "${{args[--force]}}"\n')
            
        # Create uninstall script
        uninstall_script_path = f"src/commands/uninstall/{tool}.sh"
        with open(uninstall_script_path, "w") as f:
            f.write(f'run_generic_uninstall "{tool}"\n')
            
        # Create registry template
        registry_path = f"src/lib/registry/{tool}.sh"
        if not os.path.exists(registry_path):
            tool_upper = tool.upper().replace("-", "_")
            with open(registry_path, "w") as f:
                f.write(f'{tool_upper}_INSTALL_TYPE="github_release"\n')
                f.write(f'{tool_upper}_GITHUB_REPO="TODO/TODO"\n')
                f.write(f'{tool_upper}_ARCHIVE_TYPE="binary" # or tar.gz, zip\n')
                f.write(f'{tool_upper}_ASSET_PATTERN="{tool}-${{DETECT_OS}}-${{DETECT_ARCH}}"\n\n')
                f.write(f'{tool.replace("-", "_")}_fetch_local_version() {{\n')
                f.write(f'  local target="$1"\n')
                f.write(f'  "$target" version --client --short 2>/dev/null | awk \'{{print $2}}\'\n')
                f.write(f'}}\n')

    # Write back bashly.yml
    with open(bashly_path, "w") as f:
        f.write(content)

    # Update outdated.sh tools array
    outdated_path = "src/commands/outdated.sh"
    with open(outdated_path, "r") as f:
        outdated_content = f.read()
    
    match = re.search(r'tools=\((.*?)\)', outdated_content)
    if match:
        existing_tools_str = match.group(1)
        existing_tools = [t.strip('" ') for t in existing_tools_str.split()]
        new_tools = [t for t in tools if t not in existing_tools]
        if new_tools:
            updated_tools = existing_tools + new_tools
            updated_tools_str = " ".join([f'"{t}"' for t in updated_tools])
            outdated_content = outdated_content.replace(f'tools=({existing_tools_str})', f'tools=({updated_tools_str})')
            with open(outdated_path, "w") as f:
                f.write(outdated_content)

if __name__ == "__main__":
    main()
