{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "obsidian" true {
  userPkgs = [ pkgs.obsidian ];
}
