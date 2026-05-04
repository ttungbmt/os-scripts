#!/usr/bin/env python3
import urllib.request
import json

repos = {
    "argocd": "argoproj/argo-cd",
    "velero": "vmware-tanzu/velero",
    "kubeconform": "yannh/kubeconform",
    "krew": "kubernetes-sigs/krew",
    "kubent": "doitintl/kube-no-trouble",
    "sops": "getsops/sops",
    "age": "FiloSottile/age",
    "trivy": "aquasecurity/trivy",
    "kubens": "ahmetb/kubectx",
    "kubecolor": "kubecolor/kubecolor",
    "popeye": "derailed/popeye",
    "kube-linter": "stackrox/kube-linter",
    "kyverno": "kyverno/kyverno",
    "conftest": "open-policy-agent/conftest",
    "vault": "hashicorp/vault",
    "kubeseal": "bitnami-labs/sealed-secrets"
}

for tool, repo in repos.items():
    try:
        url = f"https://api.github.com/repos/{repo}/releases/latest"
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            assets = [a['name'] for a in data.get('assets', []) if 'linux' in a['name'].lower() and ('amd64' in a['name'].lower() or 'x86_64' in a['name'].lower())]
            print(f"{tool} ({repo}): {assets[:3]}")
    except Exception as e:
        print(f"Error for {tool}: {e}")
