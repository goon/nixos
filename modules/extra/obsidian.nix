{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "obsidian" true {
    home-manager.sharedModules = [
      {
        home.packages = [ pkgs.obsidian ];
      }
    ];}