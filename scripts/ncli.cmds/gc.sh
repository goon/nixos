cmd_gc() {
  info "Collecting garbage..."
  nh clean all --keep 8
  success "Garbage collection complete!"
}
cmd_gc "$@"
