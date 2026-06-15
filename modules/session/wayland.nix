{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "wayland" true {
  options = {
    module.desktop.windowmanager = lib.mkOption {
      type = lib.types.enum [
        "hyprland"
        "mango"
      ];
      default = "hyprland";
      description = "The window manager to use.";
    };
  };

  config = {
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

  userPkgs = with pkgs; [
    wl-clipboard
    playerctl
    libnotify
    grim
    slurp
    satty
    zenity
  ];

  home = {
    services.cliphist.enable = true;

    xdg.configFile."satty/config.toml".text = ''
      [general]
      output-filename = "${config.globals.paths.home}/Pictures/Screenshots/%Y%m%d_%H%M%S.png"
      early-exit = true
      initial-tool = "brush"
      copy-command = "wl-copy"
      default-hide-toolbars = false
    '';
  };
}
