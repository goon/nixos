cmd_shell() {
  local pkgs=()
  while [ $# -gt 0 ]; do
    local pkg="$1"
    if [[ "$pkg" == *#* ]] || [[ "$pkg" == *:* ]] || [[ "$pkg" == .* ]]; then
      pkgs+=("$pkg")
    else
      pkgs+=("nixpkgs#$pkg")
    fi
    shift
  done
  
  if [ ${#pkgs[@]} -eq 0 ]; then
    error "Please specify at least one package. Usage: ncli shell <pkg>..."
  fi
  
  exec nix shell "${pkgs[@]}"
}
cmd_shell "$@"
