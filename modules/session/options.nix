{ lib, ... }:
{
  options.module.desktop.windowmanager = lib.mkOption {
    type = lib.types.enum [
      "niri"
      "hyprland"
      "mangowm"
    ];
    default = "niri";
    description = "The window manager to use.";
  };
}
