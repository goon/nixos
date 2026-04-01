{ lib, ... }:

{
  options.desktop.windowmanager = {
    name = lib.mkOption {
      type = lib.types.enum [
        "niri"
        "hyprland"
      ];
      default = "niri";
      description = "The window manager to use.";
    };
  };

  config = {
    # Conditionally import the selected WM module
    # We use lib.mkIf but we also need to make sure the files are in the imports list
  };

  imports = [
    ./niri.nix
    ./hyprland.nix
  ];
}
