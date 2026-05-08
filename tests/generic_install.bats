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

@test "run_generic_install with mise type calls mise use -g with package" {
  # Set up fake tool registry vars
  FAKE_INSTALL_TYPE="mise"
  FAKE_MISE_PKG="npm:fake-tool"

  # Stub mise to just print what it would do
  mise() { echo "mise $*"; return 0; }
  export -f mise

  # Stub command -v to say fake is NOT installed (so guard passes)
  # We override guard_existing to be a no-op since we're unit testing the mise branch
  guard_existing() { return 0; }
  export -f guard_existing

  run run_generic_install "fake" "latest" ""
  [ "$status" -eq 0 ]
  [[ "$output" == *"mise use -g npm:fake-tool"* ]]
}

@test "run_generic_install with mise type appends version to package" {
  FAKE_INSTALL_TYPE="mise"
  FAKE_MISE_PKG="npm:fake-tool"

  mise() { echo "mise $*"; return 0; }
  export -f mise

  guard_existing() { return 0; }
  export -f guard_existing

  run run_generic_install "fake" "v1.2.3" ""
  [ "$status" -eq 0 ]
  [[ "$output" == *"mise use -g npm:fake-tool@1.2.3"* ]]
}

@test "run_generic_uninstall with mise type reports not installed when binary missing" {
  source "${GT_PROJECT_ROOT}/src/lib/generic_uninstall.sh"

  FAKE_INSTALL_TYPE="mise"
  FAKE_MISE_PKG="npm:fake-tool"

  # On the test machine, "fake" won't exist — command -v returns empty naturally
  run run_generic_uninstall "fake"
  [ "$status" -eq 0 ]
  [[ "$output" == *"is not installed"* ]]
}

@test "run_generic_uninstall with mise type calls mise uninstall with package" {
  source "${GT_PROJECT_ROOT}/src/lib/generic_uninstall.sh"

  FAKE_INSTALL_TYPE="mise"
  FAKE_MISE_PKG="npm:fake-tool"

  # Stub mise
  mise() { echo "mise $*"; return 0; }
  export -f mise

  # Wrap command so "command -v fake" returns a path, other uses fall through
  command() {
    if [[ "$1" == "-v" && "$2" == "fake" ]]; then
      echo "/usr/bin/fake"
      return 0
    fi
    builtin command "$@"
  }
  export -f command

  run run_generic_uninstall "fake"
  [ "$status" -eq 0 ]
  [[ "$output" == *"mise uninstall npm:fake-tool"* ]]
}
