# Docker Compose Test Environment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tạo môi trường Docker Compose để test cài đặt các tool qua `gt` CLI trong container sạch, cô lập với máy host.

**Architecture:** Một `Dockerfile` Ubuntu 22.04 cài sẵn tất cả system dependencies (curl, tar, unzip, pip3, ruby, node), mount project directory vào `/workspace`. `docker-compose.yml` định nghĩa hai service: `shell` (interactive, để test thủ công) và `test` (tự động chạy `docker/smoke-test.sh`). Smoke test bao phủ tất cả 4 install types: `binary`, `tar.gz`, `zip`, `pip`.

**Tech Stack:** Docker, Docker Compose v2, Ubuntu 22.04, Bash, Bats 1.x.

---

## File Structure

| File | Status | Responsibility |
|---|---|---|
| `docker/Dockerfile` | **Create** | Base image với tất cả system deps cho gt |
| `docker/smoke-test.sh` | **Create** | Chạy installs đại diện cho mỗi install type, verify binary chạy được |
| `docker-compose.yml` | **Create** | Service `shell` (interactive) và `test` (automated) |

---

## Task 1: Tạo `docker/Dockerfile`

**Files:**
- Create: `docker/Dockerfile`

- [ ] **Step 1: Tạo thư mục docker/ và Dockerfile**

```bash
mkdir -p docker
```

Tạo file `docker/Dockerfile`:

```dockerfile
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    tar \
    unzip \
    git \
    bash \
    zsh \
    python3-pip \
    ruby-full \
    && rm -rf /var/lib/apt/lists/*

# Node.js 20 LTS (for claude via npm)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Bats for running unit tests inside container
RUN npm install -g bats

WORKDIR /workspace
```

- [ ] **Step 2: Build image để verify không có lỗi**

```bash
docker build -t gt-test docker/
```

Expected: build succeeds, image `gt-test` tạo thành công. `docker images gt-test` hiển thị image.

- [ ] **Step 3: Verify các deps tồn tại trong image**

```bash
docker run --rm gt-test bash -c "curl --version && tar --version && unzip -v | head -1 && pip3 --version && ruby --version && node --version && bats --version"
```

Expected: mỗi lệnh in ra version string, exit 0.

- [ ] **Step 4: Commit**

```bash
git add docker/Dockerfile
git commit -m "feat(docker): add base Dockerfile with gt system dependencies"
```

---

## Task 2: Tạo `docker-compose.yml`

**Files:**
- Create: `docker-compose.yml`

- [ ] **Step 1: Tạo docker-compose.yml ở project root**

```yaml
services:
  shell:
    build:
      context: .
      dockerfile: docker/Dockerfile
    volumes:
      - .:/workspace
    working_dir: /workspace
    environment:
      - GITHUB_TOKEN
    stdin_open: true
    tty: true

  test:
    build:
      context: .
      dockerfile: docker/Dockerfile
    volumes:
      - .:/workspace
    working_dir: /workspace
    environment:
      - GITHUB_TOKEN
    command: ["/workspace/docker/smoke-test.sh"]
```

- [ ] **Step 2: Verify service `shell` khởi động được**

```bash
docker compose run --rm shell bash -c "./gt --help"
```

Expected: hiển thị help của `gt`, bao gồm `OS Scripts CLI`, danh sách commands.

- [ ] **Step 3: Commit**

```bash
git add docker-compose.yml
git commit -m "feat(docker): add docker-compose with shell and test services"
```

---

## Task 3: Tạo `docker/smoke-test.sh`

**Files:**
- Create: `docker/smoke-test.sh`

Smoke test chạy 5 installs, mỗi cái đại diện cho một install type khác nhau:
| Tool | Install type | Lý do chọn |
|---|---|---|
| `jq` | `binary` (direct download) | Nhỏ, nhanh, không deps |
| `k9s` | `tar.gz` (GitHub release) | Archive phổ biến nhất |
| `vault` | `zip` (HashiCorp) | Duy nhất dùng zip |
| `thefuck` | `pip` | Duy nhất dùng pip |
| `kubectl` + `kustomize` | `multi` install | Test batch path |

- [ ] **Step 1: Tạo smoke-test.sh**

```bash
#!/usr/bin/env bash
set -uo pipefail

GT="/workspace/gt"
PASS=0
FAIL=0

_test() {
  local name="$1"
  local install_cmd="$2"
  local verify_cmd="$3"
  echo ""
  echo "=== Testing: $name ==="
  if eval "$install_cmd" && eval "$verify_cmd"; then
    echo "✓ $name PASSED"
    ((PASS++)) || true
  else
    echo "✗ $name FAILED"
    ((FAIL++)) || true
  fi
}

echo "Running gt smoke tests inside Docker..."
echo "GT binary: $GT"
"$GT" --version

# --- binary ---
_test "jq (binary)" \
  "$GT install jq --force" \
  "command -v jq && jq --version"

# --- tar.gz ---
_test "k9s (tar.gz)" \
  "$GT install k9s --force" \
  "command -v k9s && k9s version -s 2>/dev/null | head -1"

# --- zip ---
_test "vault (zip)" \
  "$GT install vault --force" \
  "command -v vault && vault version"

# --- pip ---
_test "thefuck (pip)" \
  "$GT install thefuck --force" \
  "command -v thefuck && thefuck --version 2>&1 | head -1"

# --- multi install ---
_test "kubectl + kustomize (multi)" \
  "$GT install multi kubectl kustomize --force" \
  "command -v kubectl && command -v kustomize"

echo ""
echo "========================================"
echo "Results: $PASS passed, $FAIL failed"
echo "========================================"

[ "$FAIL" -eq 0 ]
```

- [ ] **Step 2: Đặt quyền executable**

```bash
chmod +x docker/smoke-test.sh
```

- [ ] **Step 3: Commit**

```bash
git add docker/smoke-test.sh
git commit -m "feat(docker): add smoke-test.sh covering binary/tar.gz/zip/pip/multi install types"
```

---

## Task 4: Chạy smoke test và verify

**Verify:** `docker compose run --rm test` pass toàn bộ.

**Lưu ý:** Task này cần `GITHUB_TOKEN` để tránh GitHub API rate limit khi fetch latest version cho 5 tools. Nếu không có token, rate limit 60 req/hr có thể bị chạm khi chạy nhiều lần.

- [ ] **Step 1: Chạy smoke test đầy đủ**

```bash
GITHUB_TOKEN=<your-token> docker compose run --rm test
```

Hoặc nếu `GITHUB_TOKEN` đã được export trong shell:

```bash
docker compose run --rm test
```

Expected output:
```
Running gt smoke tests inside Docker...
GT binary: /workspace/gt
gt version 0.1.0

=== Testing: jq (binary) ===
✓ jq PASSED

=== Testing: k9s (tar.gz) ===
✓ k9s PASSED

=== Testing: vault (zip) ===
✓ vault PASSED

=== Testing: thefuck (pip) ===
✓ thefuck PASSED

=== Testing: kubectl + kustomize (multi) ===
✓ kubectl + kustomize PASSED

========================================
Results: 5 passed, 0 failed
========================================
```

Exit code: 0.

- [ ] **Step 2: Verify interactive shell service**

```bash
docker compose run --rm shell bash
```

Bên trong container:

```bash
./gt install --help   # Verify CLI hoạt động
./gt install jq       # Test một install thủ công
which jq              # Verify installed
jq --version
exit
```

- [ ] **Step 3: Verify bats unit tests chạy được trong container**

```bash
docker compose run --rm shell bash -c "npm install -g bats && bats tests/build_smoke.bats"
```

Expected: 4/4 tests pass (build smoke tests không cần network).

- [ ] **Step 4: Commit kết quả verify (nếu có file bị tạo)**

Chỉ commit nếu có file mới được sinh ra. Nếu không:

```bash
git status  # Verify working tree clean
```

---

## Hướng dẫn sử dụng sau khi hoàn thành

```bash
# Interactive shell để test thủ công
docker compose run --rm shell bash

# Chạy automated smoke test
docker compose run --rm test

# Test với GitHub token
GITHUB_TOKEN=ghp_xxxx docker compose run --rm test

# Chạy bats unit tests trong container
docker compose run --rm shell bash -c "bats tests/"

# Rebuild image sau khi thay đổi Dockerfile
docker compose build
```
