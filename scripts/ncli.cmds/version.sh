cmd_version() {
  local dirty_count
  local short_hash
  local lock_mtime
  local dirty_marker

  short_hash="$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo unknown)"
  dirty_count="$(git -C "$REPO" status --porcelain 2>/dev/null | wc -l)"
  lock_mtime="$(stat -c %y "$REPO/flake.lock" 2>/dev/null | sed 's/\..*//' || echo unknown)"

  if [ "$dirty_count" -eq 0 ]; then
    dirty_marker="(clean)"
  else
    dirty_marker="(dirty +$dirty_count)"
  fi

  echo ""
  echo "  Repo:   $short_hash $dirty_marker"
  echo "  Lock:   $lock_mtime"
  echo ""
}
cmd_version "$@"
