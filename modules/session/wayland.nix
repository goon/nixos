{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.wayland.enable =
    lib.mkEnableOption "Wayland Utilities (cliphist, wl-clipboard, etc.)"
    // {
      default = true;
    };

  config = lib.mkIf config.module.wayland.enable {
    home-manager.users.${config._module.args.username} = {
      home.packages = with pkgs; [
        cliphist
        wl-clipboard
        libnotify
      ];
    };
  };
}
