cmd_rebuild() {
  local verb="${1:-}"
  if [ -z "$verb" ]; then
    error "Usage: ncli rebuild <build|boot|switch|test|update>"
  fi
  shift
  
  case "$verb" in
    build)  exec nh os build "$@" ;;
    boot)   exec nh os boot "$@" ;;
    switch) exec nh os switch "$@" ;;
    test)   exec nh os test "$@" ;;
    update) exec nh os switch -u "$@" ;;
    *)      error "Unknown rebuild subcommand: $verb. Valid: build, boot, switch, test, update" ;;
  esac
}

cmd_rebuild "$@"
