{ config, lib, ... }:

{
  options.profile = {
    session = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf config.profile.session {
    module.hyprland.enable = lib.mkDefault true;
    module.gtk.enable = lib.mkDefault true;
    module.qt.enable = lib.mkDefault true;
    module.quickshell.enable = lib.mkDefault true;
    module.wayland.enable = lib.mkDefault true;
    module.xdg.enable = lib.mkDefault true;
  };
}
