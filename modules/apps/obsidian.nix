{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "obsidian" false {
  userPkgs = [ pkgs.obsidian ];
}
