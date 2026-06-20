if [ -f "$NCLI_DIR/../ncli.repo" ]; then
  REPO="$(cat "$NCLI_DIR/../ncli.repo")"
else
  _dir="$NCLI_DIR"
  while [ ! -f "$_dir/flake.nix" ]; do
    _dir="$(dirname "$_dir")"
    [ "$_dir" = "/" ] && error "Could not find flake.nix from $NCLI_DIR"
  done
  REPO="$_dir"
fi

MODULES_DIR="$REPO/modules"
HOSTS_DIR="$REPO/hosts"
SCRIPTS_DIR="$REPO/scripts"
FLAKE_NIX="$REPO/flake.nix"

export REPO MODULES_DIR HOSTS_DIR SCRIPTS_DIR FLAKE_NIX
cd "$REPO"
