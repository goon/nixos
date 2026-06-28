cmd_run() {
  local pkg="${1:-}"
  if [ -z "$pkg" ]; then
    error "Please specify a package to run. Usage: ncli run <pkg>"
  fi
  shift
  if [[ "$pkg" == *#* ]] || [[ "$pkg" == *:* ]] || [[ "$pkg" == .* ]]; then
    exec nix run "$pkg" -- "$@"
  else
    exec nix run "nixpkgs#$pkg" -- "$@"
  fi
}
cmd_run "$@"
