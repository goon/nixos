{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "clipboard" false {

  homeManager = {
    home.packages = [ pkgs.wl-clipboard ];
    services.cliphist.enable = true;
  };
}
