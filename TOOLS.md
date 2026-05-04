# Modern Production DevOps Platform Toolkit

> Bộ công cụ hiện đại cho DevOps, SysAdmin, Platform Engineering, Kubernetes Operations, GitOps, DevSecOps, Air-gap và Production Troubleshooting.
>
> Mục tiêu của tài liệu này là chọn **tool tốt nhất làm default** cho từng nhóm năng lực, không chỉ liệt kê tool mới hoặc tool đẹp.

---

## 1. Tools quản lý bởi `gt` CLI

25 tool được cài đặt/gỡ cài đặt/kiểm tra phiên bản bằng `gt install <tool>` / `gt uninstall <tool>` / `gt outdated`:

| Tool | Nhóm | Lệnh `gt` |
|---|---|---|
| `kubectl` | Kubernetes CLI | ✓ |
| `k9s` | Kubernetes TUI | ✓ |
| `kustomize` | K8s overlay/patch | ✓ |
| `krew` | kubectl plugin manager | ✓ |
| `kubent` | Deprecated API checker | ✓ |
| `kubens` | Namespace switcher | ✓ |
| `kubecolor` | kubectl color output | ✓ |
| `kyverno` | Policy-as-code | ✓ |
| `kube-linter` | Manifest best practices | ✓ |
| `popeye` | Cluster health audit | ✓ |
| `kubeseal` | Sealed Secrets | ✓ |
| `kubeconform` | Manifest schema validation | ✓ |
| `conftest` | Policy testing (OPA) | ✓ |
| `argocd` | GitOps CD | ✓ |
| `velero` | K8s backup/restore | ✓ |
| `sops` | Git secret encryption | ✓ |
| `age` | Encryption key backend | ✓ |
| `trivy` | Vulnerability scanner | ✓ |
| `vault` | Secrets management | ✓ |
| `direnv` | Per-project env loader | ✓ |
| `btop` | System monitor TUI | ✓ |
| `fastfetch` | System info display | ✓ |
| `zsh` | Shell (via package manager) | ✓ |
| `antidote` | Zsh plugin manager | ✓ |
| `thefuck` | CLI auto-correct | ✓ |

---

## 2. Mục tiêu thiết kế

| Nguyên tắc | Ý nghĩa |
|---|---|
| Production-first | Ưu tiên tool giúp deploy an toàn, rollback được, backup được, audit được |
| Kubernetes-native | Phù hợp Kubernetes, Helm, Helmfile, Kustomize, GitOps |
| Security-by-default | Có secrets management, vulnerability scan, SBOM, image signing, policy-as-code |
| GitOps-ready | Desired state nằm trong Git, có diff, sync, audit trail |
| Air-gap-ready | Hỗ trợ copy image, OCI artifact, offline scan, private registry |
| Minimal but complete | Không cài quá nhiều tool trùng chức năng |
| CLI + TUI balanced | CLI cho automation, TUI cho debug/thao tác nhanh |
| Best default choice | Ưu tiên công nghệ phù hợp nhất để chọn mặc định cho production platform |
| Opinionated priority | Các tool cùng loại được sắp theo thứ tự ưu tiên lựa chọn |

---

## 3. Quy ước ưu tiên

| Mức | Ý nghĩa | Cách hiểu |
|---|---|---|
| P0 | Critical / bắt buộc | Thiếu là vận hành production rủi ro |
| P1 | Core / nên cài mặc định | Nên có trên máy DevOps/Admin |
| P2 | Recommended | Cài khi team bắt đầu scale hoặc có use case rõ |
| P3 | Optional | Bổ trợ, không bắt buộc |
| LAB | Lab / học tập | Dùng để thử nghiệm, demo, local |
| PROD | Production-critical | Liên quan trực tiếp production |
| SEC | Security-critical | Liên quan bảo mật, compliance |
| AIR | Air-gap-friendly | Hợp môi trường offline/on-prem/private registry |
| K8S | Kubernetes-critical | Cần cho Kubernetes operation |

---

## 4. Quy ước đọc cột `Ưu tiên lựa chọn`

| Cú pháp | Ý nghĩa | Ví dụ |
|---|---|---|
| `A > B > C` | Ưu tiên chọn A trước, nếu không phù hợp thì chọn B, sau đó C | `taskfile > just > make` |
| `A + B` | Nên dùng kết hợp, không thay thế nhau | `jq + yq` |
| `A / B` | Chọn một trong hai tùy chiến lược/môi trường | `terraform / opentofu` |
| `A local, B server` | A phù hợp local/workstation, B phù hợp server/production | `zellij local, tmux server` |
| `A, B, C` | Các tool cùng nhóm, không có thứ tự ưu tiên mạnh | `psql, redis-cli, kcat` |

---

## 5. Executive Summary

| Nhóm năng lực | Ưu tiên lựa chọn | Mức | Lý do |
|---|---|---:|---|
| GitOps CD | `argocd / flux` | P0 PROD K8S | ArgoCD nếu cần UI/diff/audit/vận hành dễ; Flux nếu muốn controller-native thuần GitOps, không cần UI |
| Backup/DR | `velero + etcdctl + restic/kopia` | P0 PROD K8S | Velero backup K8s resource/PV; etcdctl snapshot control plane (chỉ khi self-managed); restic/kopia backup file-level |
| Policy-as-code | `ValidatingAdmissionPolicy/CEL + kyverno > gatekeeper/opa` | P0 SEC K8S | VAP/CEL native K8s cho rule đơn giản; Kyverno cho policy phức tạp, mutating, generate; OPA/Gatekeeper cho Rego/enterprise |
| Secret delivery | `external-secrets > secrets-store-csi-driver` | P0 SEC K8S | ESO sync thành Kubernetes Secret dễ dùng nhất; CSI Driver phù hợp mount secret/cert trực tiếp vào filesystem |
| Git secret encryption | `sops + age > kubeseal` | P0 SEC AIR | SOPS + age linh hoạt, hỗ trợ nhiều backend (age/pgp/kms/azure); kubeseal chỉ hợp nếu đã dùng Sealed Secrets controller |
| Supply chain security | `trivy + syft + cosign + buildx attestations` | P0 SEC | Trivy scan CVE/IaC/K8s; Syft tạo SBOM; Cosign ký/verify; buildx gắn SBOM/provenance vào build |
| Manifest safety | `kubeconform + kube-linter` | P0/P2 K8S | kubeconform validate schema/CRD (CI gate); kube-linter check best practices (không thay thế nhau) |
| Upgrade safety | `kubent > pluto` | P0 PROD K8S | kubent check deprecated API đang dùng trong cluster thật; pluto cho static analysis trong CI |
| Registry/Air-gap | `skopeo + crane + oras` | P0 AIR | skopeo copy/sync image giữa registry; crane inspect/mutate; oras push/pull OCI artifact |
| K8s daily ops | `kubectl + k9s + stern + kubecolor + krew` | P1 K8S | kubectl core bắt buộc; k9s TUI debug; stern logs multi-pod; kubecolor readability; krew plugin manager |
| K8s deployment | `helmfile > helm > kustomize raw` | P0 K8S | helmfile quản lý nhiều release/env; helm cho chart đơn; kustomize khi không dùng chart hoặc cần overlay |
| IaC/Config | `opentofu / terraform > terragrunt`, `ansible` | P1 PROD | Chọn OpenTofu (FOSS) hoặc Terraform làm IaC engine; Terragrunt wrapper cho DRY; Ansible cho VM/bare-metal/OS |
| Observability CLI | `btop > htop > top`, `lnav`, `termshark > tcpdump` | P1 PROD | btop daily monitor; htop/top fallback sẵn có; lnav parse/search log; termshark TUI; tcpdump bắt buộc biết |
| Local lab | `kind > k3d > minikube` | P1 LAB | kind chuẩn K8s API, tốt nhất cho CI; k3d nhẹ nhanh; minikube học/demo |

---

## 6. Profile Matrix

| Profile | Mục tiêu | Tool nên có |
|---|---|---|
| Workstation | Máy cá nhân DevOps/Platform Engineer | `zsh`, `starship`, `mise`, `chezmoi`, `atuin`, `eza`, `bat`, `fd`, `ripgrep`, `fzf`, `lazygit`, `k9s`, `btop` |
| Jumpbox/Bastion | Máy trung gian vào production | `tmux`, `kubectl`, `helm`, `k9s`, `stern`, `jq`, `yq`, `sops`, `age`, `trivy`, `tcpdump`, `mtr`, `htop/top` |
| CI Runner | Build/test/scan/deploy pipeline | `git`, `docker`, `buildx`, `skopeo`, `crane`, `oras`, `trivy`, `syft`, `cosign`, `gitleaks`, `kubeconform`, `helmfile` |
| K8s Admin | Quản trị cluster | `kubectl`, `k9s`, `helm`, `helmfile`, `kustomize`, `krew`, `kubent`, `popeye`, `velero`, `kyverno` |
| Security/DevSecOps | Scan, policy, compliance | `trivy`, `gitleaks`, `syft`, `grype`, `cosign`, `semgrep`, `checkov`, `kyverno`, `conftest` |
| Air-gap Ops | Môi trường offline/private registry | `skopeo`, `crane`, `oras`, `helm`, `helmfile`, `trivy`, `syft`, `cosign`, `rclone`, `rsync` |
| Database Ops | Debug DB/cache/queue | `psql`, `pgcli`, `redis-cli`, `mongosh`, `kcat`, `kafkactl`, `trino` |

---

## 7. Best Default Choices — Các nhóm dễ nhầm

| Nhóm | Best default | Không nên hiểu nhầm |
|---|---|---|
| System monitor | `btop` | `bottom` vẫn tốt nhưng ít maintained; `htop`/`top` vẫn cần biết vì có sẵn trên mọi server |
| GitOps | `argocd` | `flux` không kém — chọn theo team preference; Flux phù hợp GitOps thuần controller-native, không cần UI |
| Policy | `kyverno` | Với rule validation đơn giản nên dùng `ValidatingAdmissionPolicy/CEL` native K8s thay vì tốn thêm sidecar |
| Container runtime | `docker` vẫn là chuẩn | `nerdctl` tốt nhưng chỉ phù hợp nếu runtime là containerd không có dockerd |
| K8s production | Managed K8s (EKS/GKE/AKS) | On-prem dùng `rke2`; self-managed trên cloud hiếm khi cần thiết |
| Secret delivery | `external-secrets` | CSI Driver vẫn tốt nếu app cần secret dạng file/cert/mount trực tiếp |
| Manifest check | `kubeconform + kube-linter` (cả hai) | `kubeconform` validate schema, `kube-linter` lint best practices — không thay thế nhau |
| Supply chain | `trivy + syft + cosign` | Cần thêm build provenance/SBOM attestation từ `buildx` để đủ supply chain |
| Registry/air-gap | `skopeo` cho copy | `crane` cho inspect/ops, `oras` cho OCI artifact — bổ trợ nhau, không thay thế hoàn toàn |
| Backup K8s | `velero` | Không thay thế backup native của database (PostgreSQL WAL, MySQL binlog, Kafka) |
| IaC | `opentofu / terraform` | `terragrunt` là DRY wrapper, không phải engine; không cần Terragrunt nếu module đơn giản |
| Local K8s | `kind` | `k3d` nhanh hơn nhưng là K3s (không phải K8s chuẩn); `kind` hợp CI test chính xác hơn |
| Secrets backend | `vault` là mature default | `openbao` nếu muốn FOSS hoàn toàn sau HashiCorp BSL; `infisical` nếu ưu tiên DX |
| Runtime debug K8s | `kubectl debug` trước | Không cần `inspektor-gadget` cho hầu hết case; chỉ dùng khi cần eBPF/kernel trace |

---

## 8. Terminal, Shell & Productivity

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| Multiplexer | `tmux server > zellij local` | P0/P2 | Server/Workstation | Server dùng `tmux`; local dùng `zellij` nếu thích UI hiện đại |
| Shell | `zsh > bash` | P1 | Workstation/Jumpbox | `zsh` cho daily workflow; `bash` cho script portable |
| Prompt | `starship` | P1 | All | Prompt nhanh, đẹp, cross-shell |
| Runtime/version manager | `mise > asdf` | P1 | Workstation/CI | Quản lý Node/Python/Go/Terraform... |
| Env loader | `direnv` | P2 | Workstation | Load env theo project, dùng tốt cùng `mise` |
| Runtime + env | `mise + direnv` | P1 | Workstation/CI | `mise` quản lý version; `direnv` tự load env |
| Dotfiles | `chezmoi > stow` | P1 | Workstation | `chezmoi` mạnh cho nhiều máy, template, secret |
| Command history | `atuin > fzf-history` | P2 | Workstation | `atuin` search/sync history tốt |
| System info | `fastfetch` | P3 | Workstation | Đẹp, không production-critical |

---

## 9. Modern Core CLI

| Nhóm | Ưu tiên lựa chọn | Mức | Thay thế cho | Quy tắc chọn |
|---|---|---:|---|---|
| List file | `eza > lsd > ls` | P1 | `ls` | Dùng `eza` daily; vẫn biết `ls` cho server tối giản |
| View file | `bat > cat` | P1 | `cat` | `bat` để đọc file; `cat` cho script/pipe |
| Smart cd | `zoxide > cd` | P1 | `cd` | Tăng tốc di chuyển thư mục |
| File manager | `yazi > ranger > mc` | P2 | `mc`, `ranger` | `yazi` hiện đại, nhanh |
| Find file | `fd > find` | P1 | `find` | `fd` dễ dùng; `find` cho POSIX/server tối giản |
| Search text | `ripgrep > grep` | P1 | `grep` | `ripgrep` daily; `grep` cho script portable |
| Fuzzy finder | `fzf` | P1 | Manual search | Core cho nhiều workflow |
| Disk usage | `ncdu > duf > du/df` | P1 | `du`, `df` | `ncdu` tìm folder nặng; `duf` xem tổng quan |
| Command examples | `tldr > man` | P2 | `man` | `tldr` xem ví dụ nhanh; `man` vẫn cần khi tra sâu |
| Watch command | `viddy > watch` | P2 | `watch` | Có diff màu, xem thay đổi dễ hơn |
| Benchmark | `hyperfine > time` | P2 | `time` | Benchmark lệnh/script chính xác hơn |

---

## 10. Text Processing & Automation

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| JSON/YAML parser | `jq + yq` | P0 | All | JSON dùng `jq`; YAML dùng `yq`, không nên thay thế nhau |
| Shell quality | `shellcheck + shfmt` | P1 | Workstation/CI | `shellcheck` check lỗi; `shfmt` format |
| Script UI | `gum` | P2 | Workstation | Tạo CLI/script nội bộ có UI đẹp |
| Python automation | `python3 + uv` | P1/P2 | Workstation/CI | Python cho logic; `uv` quản lý package/runtime nhanh |
| Task runner | `taskfile > just > make` | P1 | Workstation/CI | `taskfile` cho repo lớn; `just` repo nhỏ; `make` chuẩn OSS |
| File watcher | `watchexec > entr` | P2 | Workstation | Auto-run khi file thay đổi |

---

## 11. Editor & Developer CLI

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| Terminal editor | `nvim/lazyvim > vim` | P1/P2 | Workstation/Server | `lazyvim` cho local IDE; `vim` bắt buộc biết trên server |
| VS Code CLI | `code` | P2 | Workstation | Mở project nhanh từ terminal |
| Diff viewer | `delta > diff-so-fancy > git diff` | P1 | Workstation | `delta` dễ review nhất |
| File watcher | `watchexec` | P2 | Workstation | Tự động chạy test/script khi file đổi |

---

## 12. Git & CI/CD Workflow

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| Version control | `git` | P0 | All | Bắt buộc |
| Git workflow | `lazygit + gh + git` | P1 | Workstation/CI | `git` core; `lazygit` TUI; `gh` GitHub workflow |
| Git TUI | `lazygit > gitui > git` | P1 | Workstation | `lazygit` thao tác nhanh |
| Git diff | `delta > diff-so-fancy > git diff` | P1 | Workstation | `delta` đẹp, dễ review |
| GitHub Actions local | `act` | P2 | Workstation | Test workflow local |
| Pre-commit | `pre-commit` | P2 | Workstation/CI | Chạy lint/scan trước commit |
| Secret scanner | `gitleaks` | P0 SEC | Workstation/CI | Chặn commit secret |
| Pipeline engine | `dagger` | P3 | CI | Optional khi muốn pipeline portable |

---

## 13. Container, Registry & OCI

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| Container CLI | `docker / nerdctl` | P1 | Workstation/CI/K8s | `docker` là chuẩn phổ biến nhất cho dev/local; `nerdctl` tương thích Docker CLI nhưng native containerd, phù hợp K8s node / non-Docker runtime |
| Low-level containerd | `ctr` | P2 | Admin | Debug sâu containerd, không phải daily use |
| Container TUI | `lazydocker > docker ps/logs` | P2 | Workstation | Tốt cho local/debug nhanh, không core production |
| Image analyzer | `dive` | P2 | Workstation/CI | Soi image layer, tối ưu size |
| Registry ops | `skopeo + crane + oras` | P0 AIR | CI/Air-gap | `skopeo` copy image; `crane` inspect/ops; `oras` OCI artifact |
| Image build | `buildx > docker build` | P1 | CI | `buildx` cho multi-arch/cache/SBOM/provenance attestation |
| Build engine | `buildkit` | P1 | CI | Backend build hiện đại, cache layer tốt |
| Go image build | `ko` | P3 | CI | Dành riêng Go app, không cần Dockerfile |

---

## 14. Kubernetes Daily Operations

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| K8s CLI/TUI | `kubectl + k9s` | P0/P1 K8S | Admin | `kubectl` core; `k9s` debug/thao tác nhanh |
| Context/namespace | `kubectx + kubens` | P1 K8S | Admin | Một tool đổi context, một tool đổi namespace |
| K8s deployment | `helmfile > helm > kustomize raw` | P0 K8S | Admin/CI | `helmfile` nhiều release; `helm` chart đơn; raw kustomize khi không dùng chart |
| Overlay/patch | `kustomize` | P1 K8S | Admin/CI | Hợp GitOps, patch manifest |
| Logs | `stern > kubectl logs` | P1 K8S | Admin | `stern` tail nhiều pod; `kubectl logs` cho thao tác đơn giản |
| Color output | `kubecolor > kubectl raw` | P2 K8S | Admin | Output dễ đọc hơn |
| Cluster audit | `popeye` | P2 K8S | Admin | Check health/misconfig |
| Plugin manager | `krew` | P1 K8S | Admin | Cài kubectl plugins |

---

## 15. Kubernetes Production Control

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| GitOps | `argocd > flux` | P0 PROD K8S | Platform | `argocd` dễ vận hành với UI/diff/sync; `flux` nhẹ và automation tốt |
| Image auto update | `argocd-image-updater > flux image automation` | P2 | Platform | Chọn theo GitOps engine chính |
| Progressive delivery | `argo-rollouts > native Deployment` | P2 PROD | Platform | Dùng cho canary/blue-green; Deployment thường cho app đơn giản |
| K8s backup | `velero > manual backup` | P0 PROD | Admin | Production nên có Velero |
| Etcd backup | `etcdctl` | P0 PROD | Admin | Bắt buộc nếu tự quản control plane |
| Deprecated API | `kubent > pluto` | P0 PROD | Admin/CI | Check deprecated API trước upgrade |
| Manifest safety | `kubeconform + kube-linter` | P0/P2 K8S | CI | `kubeconform` validate schema; `kube-linter` check best practice |
| Policy-as-code | `kyverno + ValidatingAdmissionPolicy/CEL > gatekeeper/opa` | P0 SEC K8S | Platform | `kyverno` đầy đủ; VAP/CEL nhẹ cho rule đơn giản; OPA/Gatekeeper cho Rego |
| Policy test | `conftest > custom scripts` | P2 SEC | CI | Test policy trước deploy |
| Runtime debug | `kubectl debug > inspektor-gadget > nsenter/tcpdump` | P2 PROD | Admin | `kubectl debug` ephemeral container không cần cài thêm; `inspektor-gadget` cho eBPF deep trace; `nsenter/tcpdump` khi SSH được vào node |
| CNI debug | `cilium + hubble` | P2 K8S | Admin | Chỉ relevant nếu cluster dùng Cilium CNI |

---

## 16. Local Kubernetes & Cluster Lifecycle

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| Local Kubernetes | `kind > k3d > minikube` | P1 LAB | Workstation/CI | `kind` chuẩn CI/test; `k3d` nhẹ nhanh; `minikube` học/demo |
| Managed K8s (Cloud) | `EKS / GKE / AKS` | P0 PROD | Platform | **Ưu tiên số 1 trên cloud** — không cần tự quản control plane; dùng cloud CLI tương ứng (`eksctl`, `gcloud`, `az`) |
| Production K8s (On-prem) | `rke2 > kubeadm` | P1 PROD | Admin | `rke2` hợp on-prem/enterprise, hardened mặc định; `kubeadm` nền tảng cần biết; `kops` chỉ dùng nếu bắt buộc self-managed trên AWS |
| Lightweight K8s | `k3s > microk8s` | P2 | Admin/LAB | Edge/IoT/lab/small cluster |
| Immutable K8s OS | `talosctl` | P2 PROD | Admin | Hướng tới cluster immutable, API-only; phù hợp đội muốn bỏ SSH vào node |
| Cluster bootstrap | `kubeadm` | P2 | Admin | Nền tảng tất cả managed installer dùng; nên biết để troubleshoot |

---

## 17. Infrastructure as Code & Config Management

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| IaC engine | `opentofu / terraform` | P1 | Platform/CI | Chọn một engine chính theo chiến lược tổ chức |
| IaC wrapper | `terragrunt > raw terraform modules` | P2 | Platform | Dùng khi nhiều env/module, cần DRY |
| Config management | `ansible` | P1 PROD | Admin/CI | Core cho VM/bare-metal/on-prem |
| Cloud CLI | `aws-cli / gcloud / az` | P2/P3 | Cloud | Cài theo cloud provider thật sự dùng |
| Cloud SSO | `granted > aws-vault` | P2 SEC | Cloud | `granted` tốt cho SSO/AssumeRole; `aws-vault` AWS-specific |

---

## 18. Secrets Management

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| Git secret | `sops + age > kubeseal` | P0 SEC AIR | GitOps/CI | `sops+age` linh hoạt hơn; `kubeseal` đơn giản |
| Secret backend | `vault / openbao / infisical` | P1 SEC | Platform | `vault` mature, enterprise-grade; `openbao` là OSS fork của Vault sau HashiCorp license change; `infisical` modern UX, developer-friendly |
| K8s secret delivery | `external-secrets > secrets-store-csi-driver` | P0 SEC K8S | Platform | ESO sync secret; CSI mount secret/cert |
| Kustomize + SOPS | `ksops` | P2 SEC | GitOps | Dùng khi Kustomize cần decrypt secret |
| Infisical K8s | `infisical-operator > infisical CLI manual sync` | P2 SEC K8S | Platform | Nếu chọn Infisical làm backend chính |

---

## 19. Security & Software Supply Chain

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| Vulnerability scan | `trivy > grype` | P0 SEC | CI/Workstation | `trivy` đa năng; `grype` tốt khi đi cùng SBOM/Syft |
| Secret scan | `gitleaks > trufflehog` | P0 SEC | CI/Workstation | `gitleaks` gọn, dễ CI |
| SBOM | `syft + buildx --sbom` | P0 SEC | CI | Tạo SBOM cho image/filesystem; buildx gắn SBOM vào build |
| Image signing | `cosign` | P0 SEC | CI/Registry | Ký/verify image/artifact |
| Provenance | `buildx --provenance + cosign attest` | P1 SEC | CI | Gắn và xác thực provenance/attestation |
| Dependency scan | `osv-scanner > npm audit/pip-audit riêng lẻ` | P2 SEC | CI | Scan dependency đa hệ sinh thái |
| SAST | `semgrep > sonarqube community` | P2 SEC | CI | `semgrep` nhẹ, dễ CI; SonarQube hợp dashboard/code quality |
| IaC security | `checkov > tfsec` | P2 SEC | CI | `checkov` rộng hơn; `tfsec` tập trung Terraform |
| Cert/PKI | `step > openssl` | P2 SEC | Admin | `step` dễ dùng hơn; `openssl` vẫn cần biết |
| Network scan | `nmap > rustscan` | P2/P3 SEC | Admin | `nmap` chuẩn cho network audit; `rustscan` (P3) nhanh hơn nhưng dễ trigger IDS/firewall nếu dùng sai ngữ cảnh |

---

## 20. Backup, Restore & Disaster Recovery

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| Kubernetes backup | `velero > manual backup` | P0 PROD | Admin | Backup resource/PV |
| Etcd backup | `etcdctl` | P0 PROD | Admin | Snapshot/restore etcd |
| File backup | `restic > kopia` | P1/P2 PROD | Admin | `restic` phổ biến, ổn định; `kopia` hiện đại, dedup tốt |
| PVC migration | `pv-migrate` | P3 PROD | Admin | Chỉ dùng khi cần migrate PVC |
| Object sync | `rclone > aws s3 cli/mc` | P1 AIR | Admin | Hợp S3/MinIO/Drive |
| Server sync | `rsync > scp` | P1 AIR | Admin | `rsync` sync tốt; `scp` copy đơn giản |
| Database backup | `database-native backup > generic PV backup` | P0 PROD | Admin/DBA | PostgreSQL/MySQL/Mongo/Kafka nên có chiến lược backup riêng, không chỉ dựa vào Velero |

---

## 21. Networking, API & Observability CLI

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| System monitor | `btop > bottom > htop > top` | P1 | Admin | `btop` tốt nhất cho daily monitor; `bottom` vẫn tốt; `htop/top` fallback |
| Log viewer | `lnav > less/tail` | P1 PROD | Admin | `lnav` parse/search/merge log tốt |
| Ping/reachability | `ping` | P0 | Admin | Bắt buộc biết; có sẵn trên mọi hệ thống |
| Network path | `trippy > mtr > traceroute` | P2/P1 | Admin | `trippy` đẹp, hiện đại; `mtr` phổ biến, hợp bastion; `traceroute` fallback |
| DNS lookup | `doggo > dig > nslookup` | P2 | Admin | `doggo` dễ đọc output; `dig` chuẩn khi debug sâu, scripting |
| Packet debug | `termshark > tcpdump` | P2/P0 PROD | Admin | `termshark` TUI xem trực quan; `tcpdump` bắt gói raw, bắt buộc biết trên production |
| HTTP/API | `httpie > curl` | P2/P0 | Admin/Dev | `httpie` dễ đọc output; `curl` bắt buộc cho script/automation/debug |
| gRPC | `grpcurl` | P2 | Microservices | Cần nếu có gRPC |
| WebSocket | `websocat` | P2 | Microservices | Cần nếu có WebSocket |
| Load test | `k6 > hey > ab` | P2 | QA/Platform | `k6` scriptable; `hey` test nhanh |
| Full metrics monitor | `glances` | P3 | Admin/LAB | Mạnh nhưng không nên bật web/API trên production nếu chưa harden |

---

## 22. Database, Queue & Data CLI

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| PostgreSQL | `psql > pgcli` | P0/P2 | Admin/Dev | `psql` chuẩn production; `pgcli` tiện local |
| Redis | `redis-cli` | P0 | Admin/Dev | Bắt buộc nếu dùng Redis |
| MongoDB | `mongosh > mongo legacy` | P2 | Admin/Dev | Nếu dùng MongoDB |
| Kafka | `kcat > kafkactl` | P1/P2 | Admin/Dev | `kcat` debug message; `kafkactl` quản trị topic/group |
| Trino | `trino` | P2 | Data/Platform | Nếu dùng Trino/lakehouse |
| Universal SQL | `usql > litecli` | P3 | Workstation | Optional |
| Supabase | `supabase` | P3 | Project-specific | Chỉ cài nếu thật sự dùng Supabase |

---

## 23. Remote Access & Transfer

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| Remote access | `ssh` | P0 | All | Bắt buộc |
| Stable SSH | `mosh > ssh` | P2/P0 | Admin | `mosh` khi mạng yếu; `ssh` vẫn là core |
| File sync | `rsync > scp` | P1 | Admin | `rsync` sync tốt hơn |
| Object sync | `rclone > cloud-specific CLI` | P1 AIR | Admin | S3/MinIO/Drive |
| File transfer | `sftp > scp` | P2 | Admin | `sftp` tương tác tốt hơn |
| Overlay VPN | `tailscale` | P2 | Admin | Nếu dùng Tailscale |
| Web terminal | `ttyd / gotty` | P3 | Admin | Chỉ dùng khi kiểm soát security tốt |

---

## 24. AI CLI & Local LLM

| Nhóm | Ưu tiên lựa chọn | Mức | Profile | Quy tắc chọn |
|---|---|---:|---|---|
| AI CLI gateway | `aichat > mods > shell-gpt` | P2/P3 | Workstation | `aichat` hợp multi-model và pipe workflow |
| Coding agent | `claude > gemini` | P2/P3 | Workstation | `claude` mạnh cho coding agent; `gemini` bổ trợ |
| Local LLM | `ollama` | P2 LAB | Workstation/Lab | Chạy model local/offline |
| AI trên production | Không khuyến nghị | - | Bastion/Prod | Tránh lộ log/secret/kubeconfig |

---

## 25. Điều chỉnh ưu tiên và lỗi hiểu nhầm phổ biến

| Tool / Nhóm | Điều chỉnh | Lý do |
|---|---|---|
| `supabase` | Hạ xuống P3, không cài mặc định | Project-specific; không phải database CLI chung |
| `thefuck` | Chỉ workstation, không cài production | Tiện dev/local nhưng không cần trên server |
| `rustscan` | Hạ xuống P3 | Nhanh nhưng dễ trigger IDS/firewall; dùng `nmap` trên production |
| `kops` | Hạ xuống P3 | Chỉ relevant nếu self-managed K8s trên AWS; hầu hết nên dùng EKS |
| `zellij` | Giữ P2 local only | Production vẫn nên ưu tiên `tmux` (audit trail, ổn định, universal) |
| `lazydocker` | Giữ P2 local only | Production ưu tiên CLI chuẩn để audit được |
| AI CLI (claude, aichat) | Không cài bastion/production | Rủi ro lộ kubeconfig/secret qua API request |
| `nerdctl > docker` ❌ | Sửa thành `docker / nerdctl` | docker vẫn là chuẩn phổ biến nhất; nerdctl chỉ khi containerd không có dockerd |
| `yq > jq` ❌ | Sửa thành `jq + yq` | JSON và YAML đều quan trọng, không thay thế nhau |
| `sops > age` ❌ | Sửa thành `sops + age` | `age` là key backend; `sops` là encryption wrapper; dùng chung, không phải thay thế |
| `k9s > kubectl` ❌ | Sửa thành `kubectl + k9s` | `kubectl` là core, `k9s` là TUI hỗ trợ; mất `kubectl` = mất script/CI |
| `kubeconform > kube-linter` ❌ | Sửa thành `kubeconform + kube-linter` | Khác mục đích: schema validation vs best practice lint |
| `bottom` làm default | Đổi thành `btop > htop > top` | `bottom` ít maintained; `btop` trực quan hơn; `top`/`htop` luôn có sẵn |
| `kyverno` trước `VAP/CEL` | Đổi thứ tự: `VAP/CEL + kyverno` | Rule đơn giản dùng VAP/CEL native không tốn sidecar; Kyverno cho policy phức tạp |
| `rke2 > kubeadm > kops` cho production | Thêm managed K8s làm ưu tiên đầu | Cloud production: EKS/GKE/AKS trước; on-prem: rke2 |

---

## 26. Recommended Installation Order

| Phase | Mục tiêu | Tool |
|---|---|---|
| Phase 1 | Daily CLI foundation | `tmux`, `zsh`, `starship`, `mise`, `eza`, `bat`, `fd`, `ripgrep`, `fzf`, `jq`, `yq`, `ncdu`, `btop` |
| Phase 2 | Git & automation | `git`, `lazygit`, `delta`, `task`, `shellcheck`, `shfmt`, `python3`, `uv`, `gitleaks` |
| Phase 3 | Container & registry | `docker`, `nerdctl`, `dive`, `skopeo`, `crane`, `oras`, `buildx`, `buildkit` |
| Phase 4 | Kubernetes daily | `kubectl`, `k9s`, `kubectx`, `kubens`, `helm`, `helmfile`, `kustomize`, `stern`, `kubecolor`, `krew` |
| Phase 5 | Kubernetes production | `argocd`, `velero`, `kyverno`, `kubeconform`, `kube-linter`, `kubent`, `popeye`, `external-secrets` |
| Phase 6 | Security supply chain | `sops`, `age`, `trivy`, `syft`, `grype`, `cosign`, `semgrep`, `checkov` |
| Phase 7 | IaC & backup | `terraform/opentofu`, `terragrunt`, `ansible`, `etcdctl`, `restic`, `kopia`, `rclone` |
| Phase 8 | Network & DB | `curl`, `httpie`, `doggo`, `tcpdump`, `termshark`, `psql`, `redis-cli`, `mongosh`, `kcat` |
| Phase 9 | AI & productivity | `aichat`, `claude`, `ollama`, `atuin`, `chezmoi`, `zellij`, `yazi` |

---

## 27. Opinionated Production Stack

| Layer | Recommended Stack |
|---|---|
| Shell | `tmux`, `zsh`, `starship`, `mise`, `chezmoi` |
| Core CLI | `eza`, `bat`, `fd`, `ripgrep`, `fzf`, `jq`, `yq`, `ncdu`, `duf` |
| System monitor | `btop`, `bottom`, `htop`, `top` |
| Git | `git`, `lazygit`, `delta`, `gitleaks`, `pre-commit` |
| Automation | `task`, `shellcheck`, `shfmt`, `python3`, `uv` |
| Container | `docker`, `nerdctl`, `skopeo`, `crane`, `oras`, `dive`, `buildx` |
| Kubernetes Daily | `kubectl`, `k9s`, `helm`, `helmfile`, `kustomize`, `stern`, `kubecolor`, `krew` |
| GitOps | `argocd`, `argocd-image-updater`, `argo-rollouts` |
| Policy | `kyverno`, `ValidatingAdmissionPolicy/CEL`, `kubeconform`, `kubent`, `kube-linter`, `conftest` |
| Secrets | `sops`, `age`, `external-secrets`, `vault`, `openbao`, `infisical` |
| Security | `trivy`, `syft`, `grype`, `cosign`, `semgrep`, `checkov` |
| Backup/DR | `velero`, `etcdctl`, `restic`, `kopia`, `rclone` |
| Network | `curl`, `httpie`, `doggo`, `tcpdump`, `termshark`, `trippy` |
| Database/Queue | `psql`, `redis-cli`, `mongosh`, `kcat`, `trino` |
| Local K8s | `kind`, `k3d`, `rke2`, `talosctl` |
| AI | `aichat`, `claude`, `ollama` |

---

## 28. Top 35 Tools For Production DevOps

| Rank | Tool | Nhóm | Vì sao ưu tiên |
|---:|---|---|---|
| 1 | `kubectl` | Kubernetes | Nền tảng mọi thao tác K8s |
| 2 | `helmfile` | Deployment | Quản lý nhiều Helm release/env |
| 3 | `argocd` | GitOps | CD theo Git, audit/rollback tốt |
| 4 | `velero` | Backup/DR | Backup/restore K8s |
| 5 | `etcdctl` | Backup/DR | Snapshot control plane |
| 6 | `kyverno` | Policy | Admission policy đầy đủ |
| 7 | `ValidatingAdmissionPolicy/CEL` | Policy | Validation đơn giản, nhẹ, native Kubernetes |
| 8 | `external-secrets` | Secrets | Secret delivery vào cluster |
| 9 | `sops` | Secrets | Encrypt secret trong Git |
| 10 | `age` | Secrets | Key encryption đơn giản |
| 11 | `trivy` | Security | CVE/IaC/K8s scanning |
| 12 | `syft` | SBOM | Generate SBOM |
| 13 | `cosign` | Supply chain | Sign/verify image |
| 14 | `kubeconform` | Validation | Validate manifests |
| 15 | `kube-linter` | Validation | Check best practices |
| 16 | `kubent` | Upgrade | Check deprecated API |
| 17 | `skopeo` | Registry | Copy image registry-to-registry |
| 18 | `crane` | Registry | Remote image operations |
| 19 | `oras` | OCI | Push/pull OCI artifacts |
| 20 | `k9s` | K8s Ops | TUI quản trị cluster |
| 21 | `stern` | Logs | Tail nhiều pod |
| 22 | `krew` | K8s Plugins | Quản lý kubectl plugins |
| 23 | `opentofu/terraform` | IaC | Provision infra |
| 24 | `ansible` | Config | VM/bare-metal automation |
| 25 | `jq` | Data | JSON processing |
| 26 | `yq` | Data | YAML processing |
| 27 | `tmux` | Terminal | Giữ session server |
| 28 | `taskfile` | Automation | Chuẩn hóa task trong repo |
| 29 | `gitleaks` | Security | Chặn leak secret |
| 30 | `buildx` | Container | Build image hiện đại |
| 31 | `restic` | Backup | Backup file-level |
| 32 | `tcpdump` | Network | Debug network production |
| 33 | `btop` | Observability | Daily system monitor tốt nhất |
| 34 | `lnav` | Logs | Đọc/search/merge log |
| 35 | `rclone` | Backup/Air-gap | Sync object storage/S3/MinIO/Drive |

---

## 29. Recommended CI Security Gates

| Stage | Ưu tiên lựa chọn | Gate |
|---|---|---|
| Pre-commit | `gitleaks` | Không cho commit secret |
| Shell quality | `shellcheck + shfmt` | Script không lỗi cơ bản, format đồng nhất |
| IaC validate | `terraform validate + checkov` | IaC hợp lệ, ít misconfig |
| Helm render | `helmfile template` | Render manifest trước |
| K8s schema | `kubeconform` | Manifest đúng schema |
| K8s lint | `kube-linter` | Manifest theo best practice |
| Policy test | `conftest + kyverno CLI` | Không vi phạm policy |
| Native admission | `ValidatingAdmissionPolicy/CEL` | Rule validation đơn giản, native Kubernetes |
| Image scan | `trivy` | Không có CVE critical/high ngoài ngưỡng |
| SBOM | `syft + buildx --sbom` | Có SBOM đi kèm build |
| Provenance | `buildx --provenance` | Có provenance attestation |
| Sign image | `cosign` | Image được ký |
| Deploy | `argocd` | Deploy qua GitOps, hạn chế apply tay |

---

## 30. Production Core YAML

```yaml
production_core:
  shell:
    priority: "tmux server > zellij local"
    tools:
      - tmux
      - zsh
      - starship
      - mise
      - chezmoi

  core_cli:
    priority: "eza + bat + fd + ripgrep + fzf + jq + yq"
    tools:
      - eza
      - bat
      - fd
      - ripgrep
      - fzf
      - jq
      - yq
      - ncdu
      - duf

  observability_cli:
    priority: "btop > bottom > htop > top, lnav, termshark > tcpdump"
    tools:
      - btop
      - bottom
      - htop
      - lnav
      - termshark
      - tcpdump
      - trippy
      - doggo

  git_automation:
    priority: "lazygit + gh + git, taskfile > just > make"
    tools:
      - git
      - lazygit
      - gh
      - delta
      - task
      - just
      - make
      - shellcheck
      - shfmt
      - gitleaks

  container_registry:
    priority: "nerdctl > docker, skopeo + crane + oras"
    tools:
      - docker
      - nerdctl
      - skopeo
      - crane
      - oras
      - buildx
      - dive

  kubernetes:
    priority: "kubectl + k9s, helmfile > helm > kustomize raw"
    tools:
      - kubectl
      - k9s
      - helm
      - helmfile
      - kustomize
      - stern
      - kubecolor
      - krew
      - argocd

  production_control:
    priority: "argocd + velero + kyverno + ValidatingAdmissionPolicy/CEL + external-secrets"
    tools:
      - argocd
      - velero
      - etcdctl
      - kyverno
      - validating-admission-policy
      - kubeconform
      - kube-linter
      - kubent
      - external-secrets

  security_supply_chain:
    priority: "trivy + syft + cosign + buildx attestations"
    tools:
      - sops
      - age
      - trivy
      - syft
      - grype
      - cosign
      - semgrep
      - checkov
      - buildx

  iac:
    priority: "opentofu / terraform > terragrunt, ansible"
    tools:
      - opentofu
      - terraform
      - terragrunt
      - ansible

  backup_transfer:
    priority: "velero + etcdctl, restic > kopia, rclone > rsync"
    tools:
      - velero
      - etcdctl
      - restic
      - kopia
      - rclone
      - rsync

  network:
    priority: "httpie > curl, termshark > tcpdump, trippy > mtr"
    tools:
      - curl
      - httpie
      - tcpdump
      - termshark
      - doggo
      - trippy

  database:
    priority: "psql > pgcli, kcat > kafkactl"
    tools:
      - psql
      - pgcli
      - redis-cli
      - mongosh
      - kcat
      - kafkactl
```

---

## 31. Kết luận

Bản toolkit này chuyển trọng tâm từ:

```text
Modern CLI collection
```

sang:

```text
Production DevOps Platform Toolkit
```

Khác biệt lớn nhất là bổ sung và chuẩn hóa các năng lực production thật sự:

| Năng lực | Ưu tiên lựa chọn |
|---|---|
| GitOps | `argocd > flux` |
| Backup/DR | `velero + etcdctl + restic/kopia` |
| Policy-as-code | `kyverno + ValidatingAdmissionPolicy/CEL > gatekeeper/opa` |
| Manifest safety | `kubeconform + kube-linter`, `kubent > pluto` |
| Secret delivery | `external-secrets > secrets-store-csi-driver` |
| Git secret | `sops + age > kubeseal` |
| Supply chain security | `trivy + syft + cosign + buildx attestations` |
| Air-gap/registry | `skopeo + crane + oras` |
| Runtime debug | `k9s + stern + inspektor-gadget + tcpdump + termshark` |
| System monitor | `btop > bottom > htop > top` |
| Task automation | `taskfile > just > make` |

> Một bộ DevOps toolkit tốt không phải là bộ có nhiều tool nhất, mà là bộ giúp deploy an toàn hơn, debug nhanh hơn, bảo mật tốt hơn, rollback được và restore được khi production gặp sự cố.
