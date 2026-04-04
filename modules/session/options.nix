{ lib, ... }:
{
  options.module.desktop.windowmanager = lib.mkOption {
    type = lib.types.enum [
      "niri"
      "hyprland"
    ];
    default = "niri";
    description = "The window manager to use.";
  };
}
