{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "utils" true {
  userPkgs = with pkgs; [
    fd
    gum
    ripgrep
    wget
    curl
    unzip
    btop
    jq
  ];
}
