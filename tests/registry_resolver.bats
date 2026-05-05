#!/usr/bin/env bats

load test_helper

setup() {
  source "${GT_PROJECT_ROOT}/tests/fixtures/fake-registry.sh"
}

_substitute_url() {
  local template="$1"
  local version="$2"
  local os="$3"
  local arch="$4"
  local result="${template//\$\{VERSION\}/$version}"
  result="${result//\$\{DETECT_OS\}/$os}"
  result="${result//\$\{DETECT_ARCH\}/$arch}"
  echo "$result"
}

@test "asset URL substitutes VERSION/OS/ARCH placeholders" {
  run _substitute_url "$FAKETOOL_ASSET_URL" "v1.2.3" "linux" "amd64"
  [ "$status" -eq 0 ]
  [ "$output" = "https://example.com/faketool/v1.2.3/faketool-linux-amd64" ]
}

@test "asset URL substitutes for darwin/arm64" {
  run _substitute_url "$FAKETOOL_ASSET_URL" "v1.2.3" "darwin" "arm64"
  [ "$status" -eq 0 ]
  [ "$output" = "https://example.com/faketool/v1.2.3/faketool-darwin-arm64" ]
}
