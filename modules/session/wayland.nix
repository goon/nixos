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
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      GDK_BACKEND = "wayland,x11";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      MOZ_ENABLE_WAYLAND = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      GTK_USE_PORTAL = "1";
      XDG_SESSION_TYPE = "wayland";
      MOZ_DBUS_REMOTE = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_SCALE_FACTOR = "1";
      QT_FONT_DPI = "96";
    };

    home-manager.users.${config._module.args.username} = {
      home.packages = with pkgs; [
        wl-clipboard
        wlsunset
        playerctl
        libnotify
      ];
      services.cliphist.enable = true;
    };
  };
}
