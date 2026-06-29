{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "screenshot" false {

  includes = [ "clipboard" ];

  homeManager = {
    home.packages = with pkgs; [
      grim
      slurp
      satty
    ];

    xdg.configFile."satty/config.toml".text = ''
      [general]
      output-filename = "''${config.globals.paths.home}/Pictures/Screenshots/%Y%m%d_%H%M%S.png"
      early-exit = true
      initial-tool = "brush"
      copy-command = "wl-copy"
      default-hide-toolbars = false
    '';
  };
}
