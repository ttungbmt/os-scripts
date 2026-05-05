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

# binary
_test "jq (binary)" \
  "$GT install jq --force" \
  "command -v jq && jq --version"

# tar.gz
_test "k9s (tar.gz)" \
  "$GT install k9s --force" \
  "command -v k9s && k9s version -s 2>/dev/null | head -1"

# zip
_test "vault (zip)" \
  "$GT install vault --force" \
  "command -v vault && vault version"

# pip
_test "thefuck (pip)" \
  "$GT install thefuck --force" \
  "command -v thefuck && thefuck --version 2>&1 | head -1"

# multi install
_test "kubectl + kustomize (multi)" \
  "$GT install multi kubectl kustomize --force" \
  "command -v kubectl && command -v kustomize"

echo ""
echo "========================================"
echo "Results: $PASS passed, $FAIL failed"
echo "========================================"

[ "$FAIL" -eq 0 ]
