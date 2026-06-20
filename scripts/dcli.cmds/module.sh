cmd_module() {
  local verb="${1:-list}"
  shift 2>/dev/null || true
  case "$verb" in
    list) cmd_module_list "$@" ;;
    *) error "Unknown module subcommand: $verb. Valid: list" ;;
  esac
}

cmd_module_list() {
  local requested_host="${1:-}"
  local host=""
  local hosts_list=""

  if [ -z "$requested_host" ]; then
    host="$(hostname -s 2>/dev/null || true)"
    if [ -z "$host" ] || ! host_dashboard_exists "$host"; then
      hosts_list="$(discover_hosts | awk '{printf "%s%s", sep, $0; sep=", "} END{print ""}')"
      if [ -z "$host" ]; then
        error "Could not determine hostname. Available hosts: $hosts_list"
      else
        error "Current host '$host' has no dashboard. Available hosts: $hosts_list"
      fi
    fi
  else
    if ! host_dashboard_exists "$requested_host"; then
      hosts_list="$(discover_hosts | awk '{printf "%s%s", sep, $0; sep=", "} END{print ""}')"
      error "Host '$requested_host' not found. Available hosts: $hosts_list"
    fi
    host="$requested_host"
  fi

  echo ""
  info "Modules on $host"
  echo ""

  local enabled_list
  enabled_list="$(host_dashboard_enabled "$host")"

  local current_category=""
  local on_names=""
  local off_names=""
  local always_names=""

  while IFS=' ' read -r category name; do
    if [ "$category" != "$current_category" ]; then
      if [ -n "$current_category" ]; then
        print_category_group "$current_category" "$always_names" "$on_names" "$off_names"
      fi
      current_category="$category"
      on_names=""
      off_names=""
      always_names=""
    fi

    case "$category" in
      core|shared)
        always_names="${always_names}${name}, "
        ;;
      *)
        if echo "$enabled_list" | grep -q "^$name true$"; then
          on_names="${on_names}${name}, "
        else
          off_names="${off_names}${name}, "
        fi
        ;;
    esac
  done < <(discover_modules_raw)

  if [ -n "$current_category" ]; then
    print_category_group "$current_category" "$always_names" "$on_names" "$off_names"
  fi
}

print_category_group() {
  local category="$1"
  local always="$2"
  local on="$3"
  local off="$4"

  always="${always%, }"
  on="${on%, }"
  off="${off%, }"

  case "$category" in
    core|shared)
      echo "  $category (always on):"
      echo "    $always"
      echo ""
      ;;
    *)
      echo "  $category:"
      if [ -n "$on" ]; then
        echo -e "    ${GR}[on]${NC}  $on"
      fi
      if [ -n "$off" ]; then
        echo -e "    ${YE}[off]${NC} $off"
      fi
      echo ""
      ;;
  esac
}

cmd_module "$@"
