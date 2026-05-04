#!/usr/bin/env python3
import os

configs = {
    "argocd": {
        "repo": "argoproj/argo-cd",
        "archive": "binary",
        "pattern": "argocd-${DETECT_OS}-${DETECT_ARCH}"
    },
    "velero": {
        "repo": "vmware-tanzu/velero",
        "archive": "tar.gz",
        "pattern": "velero-v${VERSION}-${DETECT_OS}-${DETECT_ARCH}.tar.gz",
        "bin_path": "velero-v${VERSION}-${DETECT_OS}-${DETECT_ARCH}/velero"
    },
    "kubeconform": {
        "repo": "yannh/kubeconform",
        "archive": "tar.gz",
        "pattern": "kubeconform-${DETECT_OS}-${DETECT_ARCH}.tar.gz"
    },
    "krew": {
        "repo": "kubernetes-sigs/krew",
        "archive": "tar.gz",
        "pattern": "krew-${DETECT_OS}_${DETECT_ARCH}.tar.gz",
        "bin_path": "krew-${DETECT_OS}_${DETECT_ARCH}"
    },
    "kubent": {
        "repo": "doitintl/kube-no-trouble",
        "archive": "tar.gz",
        "pattern": "kubent-${VERSION}-${DETECT_OS}-${DETECT_ARCH}.tar.gz"
    },
    "sops": {
        "repo": "getsops/sops",
        "archive": "binary",
        "pattern": "sops-v${VERSION}.${DETECT_OS}.${DETECT_ARCH}"
    },
    "age": {
        "repo": "FiloSottile/age",
        "archive": "tar.gz",
        "pattern": "age-v${VERSION}-${DETECT_OS}-${DETECT_ARCH}.tar.gz",
        "bin_path": "age/age" # inside folder age
    },
    "trivy": {
        "repo": "aquasecurity/trivy",
        "archive": "tar.gz",
        "pattern": "trivy_${VERSION}_${DETECT_OS_CAP}_64bit.tar.gz", # requires custom mapping Linux
        "os_map_linux": "Linux",
        "os_map_darwin": "macOS",
        "arch_map_amd64": "64bit",
        "arch_map_arm64": "ARM64"
    },
    "kubens": {
        "repo": "ahmetb/kubectx",
        "archive": "tar.gz",
        "pattern": "kubens_v${VERSION}_${DETECT_OS}_x86_64.tar.gz", # wait x86_64 mapping
        "arch_map_amd64": "x86_64"
    },
    "kubecolor": {
        "repo": "kubecolor/kubecolor",
        "archive": "tar.gz",
        "pattern": "kubecolor_${VERSION}_${DETECT_OS}_${DETECT_ARCH}.tar.gz"
    },
    "popeye": {
        "repo": "derailed/popeye",
        "archive": "tar.gz",
        "pattern": "popeye_${DETECT_OS}_${DETECT_ARCH}.tar.gz" # actually usually popeye_Linux_x86_64.tar.gz
    },
    "kube-linter": {
        "repo": "stackrox/kube-linter",
        "archive": "tar.gz",
        "pattern": "kube-linter-${DETECT_OS}.tar.gz" # they don't seem to append arch in older? Actually they do now: kube-linter-linux-amd64.tar.gz
    },
    "kyverno": {
        "repo": "kyverno/kyverno",
        "archive": "tar.gz",
        "pattern": "kyverno-cli_v${VERSION}_${DETECT_OS}_x86_64.tar.gz",
        "arch_map_amd64": "x86_64",
        "bin_path": "kyverno"
    },
    "conftest": {
        "repo": "open-policy-agent/conftest",
        "archive": "tar.gz",
        "pattern": "conftest_${VERSION}_${DETECT_OS}_x86_64.tar.gz",
        "arch_map_amd64": "x86_64"
    },
    "vault": {
        "repo": "hashicorp/vault",
        "archive": "zip",
        "pattern": "vault_${VERSION}_${DETECT_OS}_${DETECT_ARCH}.zip",
        "url": "https://releases.hashicorp.com/vault/${VERSION}/vault_${VERSION}_${DETECT_OS}_${DETECT_ARCH}.zip"
    },
    "kubeseal": {
        "repo": "bitnami-labs/sealed-secrets",
        "archive": "tar.gz",
        "pattern": "kubeseal-${VERSION}-${DETECT_OS}-${DETECT_ARCH}.tar.gz"
    }
}

for tool, c in configs.items():
    file_path = f"src/lib/registry/{tool}.sh"
    tool_upper = tool.upper().replace("-", "_")
    content = f"""{tool_upper}_INSTALL_TYPE="github_release"
{tool_upper}_GITHUB_REPO="{c.get('repo')}"
{tool_upper}_ARCHIVE_TYPE="{c.get('archive')}"
{tool_upper}_ASSET_PATTERN="{c.get('pattern')}"
"""
    if 'bin_path' in c:
        content += f"{tool_upper}_BIN_PATH=\"{c['bin_path']}\"\n"
    if 'url' in c:
        content += f"{tool_upper}_DOWNLOAD_URL=\"{c['url']}\"\n"
    if 'os_map_linux' in c:
        content += f"{tool_upper}_OS_MAP_linux=\"{c['os_map_linux']}\"\n"
    if 'os_map_darwin' in c:
        content += f"{tool_upper}_OS_MAP_darwin=\"{c['os_map_darwin']}\"\n"
    if 'arch_map_amd64' in c:
        content += f"{tool_upper}_ARCH_MAP_amd64=\"{c['arch_map_amd64']}\"\n"
    if 'arch_map_arm64' in c:
        content += f"{tool_upper}_ARCH_MAP_arm64=\"{c['arch_map_arm64']}\"\n"
        
    content += f"""
{tool.replace("-", "_")}_fetch_local_version() {{
  local target="$1"
  "$target" version --client --short 2>/dev/null | awk '{{print $2}}' || "$target" --version 2>/dev/null | awk '{{print $3}}'
}}
"""
    with open(file_path, "w") as f:
        f.write(content)

print("Registry files updated.")
