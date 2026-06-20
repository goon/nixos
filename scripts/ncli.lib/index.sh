if [ -n "${__NCLI_INDEX_SOURCED:-}" ]; then return; fi
__NCLI_INDEX_SOURCED=1

source "$NCLI_DIR/ncli.lib/colors.sh"
source "$NCLI_DIR/ncli.lib/paths.sh"
source "$NCLI_DIR/ncli.lib/discover.sh"
source "$NCLI_DIR/ncli.lib/hosts.sh"
