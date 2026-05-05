#!/usr/bin/env bats

load test_helper

setup() {
  source "${GT_PROJECT_ROOT}/src/lib/install_helpers.sh"
  source "${GT_PROJECT_ROOT}/src/lib/colors.sh"
  source "${GT_PROJECT_ROOT}/src/lib/generic_install.sh"

  TARGET_DIR="${BATS_TEST_TMPDIR}/bin"
  mkdir -p "$TARGET_DIR"

  EXTRACT_DIR="${BATS_TEST_TMPDIR}/extracted"
  mkdir -p "$EXTRACT_DIR"
  tar -xzf "${GT_PROJECT_ROOT}/tests/fixtures/fake-tool.tar.gz" -C "$EXTRACT_DIR"
}

@test "_install_from_extracted_dir copies binary from nested subdir" {
  run _install_from_extracted_dir "fake-tool" "$EXTRACT_DIR" "fake-tool-1.0.0/bin/fake-tool" "$TARGET_DIR/fake-tool"
  [ "$status" -eq 0 ]
  [ -x "$TARGET_DIR/fake-tool" ]
  run "$TARGET_DIR/fake-tool"
  [ "$output" = "fake v1.0.0" ]
}
