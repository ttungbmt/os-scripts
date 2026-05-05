#!/usr/bin/env bats

load test_helper

@test "bashly generate produces gt without errors" {
  cd "${GT_PROJECT_ROOT}"
  run bashly generate
  [ "$status" -eq 0 ]
  [ -x "./gt" ]
}

@test "generated gt passes bash syntax check" {
  run bash -n "${GT_BIN}"
  [ "$status" -eq 0 ]
}

@test "gt --help mentions OS Scripts CLI" {
  run "${GT_BIN}" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"OS Scripts CLI"* ]]
}

@test "gt install --help lists at least 30 tool subcommands" {
  run "${GT_BIN}" install --help
  [ "$status" -eq 0 ]
  local count
  count=$(echo "$output" | grep -cE '^  [a-z][a-z0-9-]+ ' || true)
  [ "$count" -ge 30 ]
}
