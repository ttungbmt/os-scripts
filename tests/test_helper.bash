export GT_PROJECT_ROOT
GT_PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export GT_BIN="${GT_PROJECT_ROOT}/gt"

gt_regenerate() {
  (cd "${GT_PROJECT_ROOT}" && bashly generate >/dev/null 2>&1)
}
