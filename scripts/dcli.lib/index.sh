if [ -n "${__DCLI_INDEX_SOURCED:-}" ]; then return; fi
__DCLI_INDEX_SOURCED=1

source "$DCLI_DIR/dcli.lib/colors.sh"
source "$DCLI_DIR/dcli.lib/paths.sh"
source "$DCLI_DIR/dcli.lib/discover.sh"
source "$DCLI_DIR/dcli.lib/hosts.sh"
