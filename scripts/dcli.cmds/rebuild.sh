cmd_rebuild() {
  info "Rebuilding system..."
  nh os switch
  success "Rebuild complete!"
}
cmd_rebuild "$@"
