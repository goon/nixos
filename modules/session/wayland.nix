{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.desktop.windowmanager = lib.mkOption {
    type = lib.types.enum [
      "hyprland"
      "mango"
    ];
    default = "hyprland";
    description = "The window manager to use.";
  };

  options.module.wayland.enable =
    lib.mkEnableOption "Wayland Utilities (cliphist, wl-clipboard, etc.)"
    // {
      default = true;
    };

  config = lib.mkIf config.module.wayland.enable {
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      QT_QPA_PLATFORM = "wayland";
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
        playerctl
        libnotify
        grim
        slurp
        swappy
      ];
      services.cliphist.enable = true;

      xdg.configFile."swappy/config".text = ''
        [Default]
        save_dir=${config.globals.paths.home}/Pictures/Screenshots
        save_filename_format=swappy-%Y%m%d-%H%M%S.png
        show_panel=false
        line_size=5
        text_size=20
        text_font=sans-serif
        paint_mode=brush
        early_exit=true
        fill_shape=false
      '';
    };
  };
}
