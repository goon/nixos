discover_modules() {
  local modules_dir="$MODULES_DIR"
  for category_dir in "$modules_dir"/*/; do
    [ -d "$category_dir" ] || continue
    category="$(basename "$category_dir")"
    case "$category" in _*) continue ;; .*) continue ;; globals) continue ;; esac
    for entry in "$category_dir"*; do
      [ -e "$entry" ] || continue
      name="$(basename "$entry")"
      case "$name" in _*) continue ;; .*) continue ;; esac
      if [ -d "$entry" ]; then
        [ -f "$entry/default.nix" ] || continue
        [ -f "$entry/.git" ] && continue
        echo "$category $name"
      elif [ -f "$entry" ] && [[ "$name" == *.nix ]] && [ "$name" != "default.nix" ]; then
        echo "$category ${name%.nix}"
      fi
    done
  done
}

discover_modules_raw() {
  discover_modules | sort -k1,1 -k2,2
}
