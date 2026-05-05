#!/usr/bin/env bats

load test_helper

setup() {
  source "${GT_PROJECT_ROOT}/src/lib/version_helpers.sh"
  STUB_DIR="${BATS_TEST_TMPDIR}/bin"
  mkdir -p "$STUB_DIR"
}

@test "get_local_version handles plain tool name" {
  cat > "$STUB_DIR/faketool" <<'EOF'
#!/bin/sh
echo "faketool v2.5.0"
EOF
  chmod +x "$STUB_DIR/faketool"
  PATH="$STUB_DIR:$PATH"

  run get_local_version "faketool"
  [ "$status" -eq 0 ]
  [[ "$output" == *"2.5.0"* ]]
}

@test "get_local_version handles hyphenated tool name (kube-linter)" {
  cat > "$STUB_DIR/kube-linter" <<'EOF'
#!/bin/sh
echo "kube-linter v0.6.8"
EOF
  chmod +x "$STUB_DIR/kube-linter"
  PATH="$STUB_DIR:$PATH"

  run get_local_version "kube-linter"
  [ "$status" -eq 0 ]
  [[ "$output" == *"0.6.8"* ]]
}
