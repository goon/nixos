discover_hosts() {
  for dir in "$HOSTS_DIR"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    case "$name" in _*) continue ;; .*) continue ;; esac
    [ -f "$dir/default.nix" ] || continue
    echo "$name"
  done
}

host_dashboard_path() {
  local host="$1"
  echo "$HOSTS_DIR/$host/default.nix"
}

host_dashboard_exists() {
  local host="$1"
  [ -f "$HOSTS_DIR/$host/default.nix" ]
}

host_dashboard_enabled() {
  local host="$1"
  local dashboard="$HOSTS_DIR/$host/default.nix"
  if [ -f "$dashboard" ]; then
    grep -E '^[[:space:]]*module\.[a-zA-Z0-9_-]+\.enable[[:space:]]*=[[:space:]]*(true|false);' "$dashboard" | \
      sed -E 's/.*module\.([a-zA-Z0-9_-]+)\.enable.*=.*(true|false).*/\1 \2/'
  fi
}
