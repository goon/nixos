{
  config,
  lib,
  ...
}:
{
  options.profile = {
    session = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf config.profile.session {
    module.hyprland = lib.mkDefault true;
    module.gtk = lib.mkDefault true;
    module.qt = lib.mkDefault true;
    module.quickshell = lib.mkDefault true;
    module.wayland = lib.mkDefault true;
    module.xdg = lib.mkDefault true;
  };
}
