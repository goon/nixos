cmd_module() {
  local verb="${1:-list}"
  shift 2>/dev/null || true
  case "$verb" in
    list) cmd_module_list "$@" ;;
    enable) cmd_module_enable "$@" ;;
    disable) cmd_module_disable "$@" ;;
    *) error "Unknown module subcommand: $verb. Valid: list, enable, disable" ;;
  esac
}

get_host() {
  local requested_host="${1:-}"
  local host=""
  if [ -z "$requested_host" ]; then
    host="$(hostname -s 2>/dev/null || true)"
    if [ -z "$host" ] || ! host_dashboard_exists "$host"; then
      local hosts_list="$(discover_hosts | awk '{printf "%s%s", sep, $0; sep=", "} END{print ""}')"
      error "Could not determine hostname or host has no dashboard. Available hosts: $hosts_list"
    fi
  else
    if ! host_dashboard_exists "$requested_host"; then
      local hosts_list="$(discover_hosts | awk '{printf "%s%s", sep, $0; sep=", "} END{print ""}')"
      error "Host '$requested_host' not found. Available hosts: $hosts_list"
    fi
    host="$requested_host"
  fi
  echo "$host"
}

cmd_module_list() {
  local host="$(get_host "${1:-}")"
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

cmd_module_enable() {
  local module_name="${1:-}"
  if [ -z "$module_name" ]; then
    error "Please specify a module to enable. Usage: ncli module enable <name> [host]"
  fi
  local host="$(get_host "${2:-}")"
  local dashboard="$HOSTS_DIR/$host/default.nix"
  
  # Check if module exists
  local module_exists=false
  while IFS=' ' read -r category name; do
    if [ "$name" = "$module_name" ]; then
      module_exists=true
      break
    fi
  done < <(discover_modules_raw)
  
  if ! $module_exists; then
    error "Module '$module_name' does not exist."
  fi
  
  if grep -qE "^[[:space:]]*module\.$module_name\.enable[[:space:]]*=" "$dashboard"; then
    sed -i -E "s/^[[:space:]]*module\.$module_name\.enable[[:space:]]*=.*$/  module.$module_name.enable = true;/" "$dashboard"
  else
    # Insert before the last closing brace
    sed -i -E "/^}/i \ \ module.$module_name.enable = true;" "$dashboard"
  fi
  
  success "Enabled module '$module_name' on host '$host'."
}

cmd_module_disable() {
  local module_name="${1:-}"
  if [ -z "$module_name" ]; then
    error "Please specify a module to disable. Usage: ncli module disable <name> [host]"
  fi
  local host="$(get_host "${2:-}")"
  local dashboard="$HOSTS_DIR/$host/default.nix"
  
  if grep -qE "^[[:space:]]*module\.$module_name\.enable[[:space:]]*=" "$dashboard"; then
    sed -i -E "s/^[[:space:]]*module\.$module_name\.enable[[:space:]]*=.*$/  module.$module_name.enable = false;/" "$dashboard"
    success "Disabled module '$module_name' on host '$host'."
  else
    success "Module '$module_name' was not enabled on host '$host'."
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
