{
  config,
  lib,
  pkgs,
  ...
}:
lib.module config "obsidian" false {
  homeManager = _: {
    home.packages = [ pkgs.obsidian ];
  };
}
