all=${args[--all]}
target_tool=${args[tool]}

if [ -n "$target_tool" ]; then
  tools=("$target_tool" "argocd" "velero" "kubeconform" "krew" "kubent" "sops" "age" "trivy" "kubens" "kubecolor" "popeye" "kube-linter" "kyverno" "conftest" "vault" "kubeseal")
  all=1 # Force check even if not installed
else
  tools=("kustomize" "k9s" "kubectl" "fastfetch" "direnv" "thefuck" "btop")
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
