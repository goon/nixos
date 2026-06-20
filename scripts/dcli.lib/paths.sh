if [ -f "$DCLI_DIR/../dcli.repo" ]; then
  REPO="$(cat "$DCLI_DIR/../dcli.repo")"
else
  _dir="$DCLI_DIR"
  while [ ! -f "$_dir/flake.nix" ]; do
    _dir="$(dirname "$_dir")"
    [ "$_dir" = "/" ] && error "Could not find flake.nix from $DCLI_DIR"
  done
  REPO="$_dir"
fi

MODULES_DIR="$REPO/modules"
HOSTS_DIR="$REPO/hosts"
SCRIPTS_DIR="$REPO/scripts"
FLAKE_NIX="$REPO/flake.nix"

export REPO MODULES_DIR HOSTS_DIR SCRIPTS_DIR FLAKE_NIX
cd "$REPO"
