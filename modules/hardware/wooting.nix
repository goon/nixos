{
  pkgs,
  config,
  lib,
  ...
}:

lib.module config "wooting" false {
  services.udev.packages = [ pkgs.wooting-udev-rules ];
  environment.systemPackages = [ pkgs.wootility ];
}
