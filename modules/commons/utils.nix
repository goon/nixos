{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "utils" true {
    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
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
    ];}