cmd_fmt() {
  info "Formatting Nix files..."
  nix fmt
  success "Format complete!"
}
cmd_fmt "$@"
