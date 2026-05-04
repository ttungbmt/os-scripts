# lib/_lib.sh — aggregator. Source this to load all installer helpers.
#
#   _LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "${_LIB_DIR}/lib/_lib.sh"

[ -n "${_LIB_AGG_LOADED:-}" ] && return 0
_LIB_AGG_LOADED=1

_LIB_DIR_THIS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Order matters: log first (others depend on die/log), then deps fan out.
# shellcheck source=log.sh
source "${_LIB_DIR_THIS}/log.sh"
# shellcheck source=os.sh
source "${_LIB_DIR_THIS}/os.sh"
# shellcheck source=download.sh
source "${_LIB_DIR_THIS}/download.sh"
# shellcheck source=github.sh
source "${_LIB_DIR_THIS}/github.sh"
# shellcheck source=install.sh
source "${_LIB_DIR_THIS}/install.sh"
# shellcheck source=version.sh
source "${_LIB_DIR_THIS}/version.sh"
