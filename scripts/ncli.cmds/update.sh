cmd_update() {
  info "Updating flake inputs and rebuilding..."
  nh os switch -u
  success "Update complete!"
}
cmd_update "$@"
