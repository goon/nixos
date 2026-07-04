{
  config,
  lib,
  pkgs,
  ...
}:
lib.module config "wayland" false {
  config = {
    module.clipboard = true;
    module.screenshot = true;
    module.xdg = true;
    module.gtk = true;
    module.qt = true;
    module.quickshell = true;
    module.fonts = true;
    module.greeter = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      MOZ_ENABLE_WAYLAND = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      XDG_SESSION_TYPE = "wayland";
      MOZ_DBUS_REMOTE = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    programs.gpu-screen-recorder.enable = true;
  };

  homeManager = {
    home.packages = with pkgs; [
      playerctl
      libnotify
      zenity
    ];
  };
}
