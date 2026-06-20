cmd_generations() {
  sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | head -50
}
cmd_generations "$@"
