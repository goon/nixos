{ lib, ... }:
{
  options.module.desktop.windowmanager = lib.mkOption {
    type = lib.types.enum [
      "hyprland"
      "mangowm"
    ];
    default = "hyprland";
    description = "The window manager to use.";
  };
}
