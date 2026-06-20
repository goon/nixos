cmd_test() {
  info "Testing configuration..."
  nh os test
  success "Test complete!"
}
cmd_test "$@"
