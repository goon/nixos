{
  pkgs,
  config,
  lib,
  ...
}:

lib.module config "monitors" false {
  environment.systemPackages = with pkgs; [
    brightnessctl
    ddcutil
  ];
}
