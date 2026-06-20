{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "gtk" false {
  config = {
    # ========== System Layer (NixOS) ==========
    services.dbus.enable = true;
    programs.dconf.enable = true;
  };

  userPkgs = with pkgs; [
    # Theming
    adw-gtk3
    papirus-icon-theme
    bibata-cursors
    glib
    gtk3
  ];

  home = { config, globals, ... }: {
    dconf.enable = true;

    home.pointerCursor = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 28;
      gtk.enable = true;
      x11.enable = true;
    };

    # Interface Theming
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        font-name = "${globals.userFonts.sansSerif} 11";
        document-font-name = "${globals.userFonts.sansSerif} 11";
        monospace-font-name = "${globals.userFonts.monospace} 11";
        gtk-theme = "adw-gtk3";
        icon-theme = "Papirus";
      };
    };

    # GTK Bookmarks
    xdg.configFile."gtk-3.0/bookmarks" = {
      force = true;
      text = ''
        file://${globals.repo} Nix
        file://${globals.paths.home}/Downloads Downloads
        file://${globals.paths.home}/Documents Documents
        file://${globals.paths.home}/Pictures Pictures
        file://${globals.paths.home}/Music Music
        file://${globals.paths.home}/Videos Videos
        file://${config.xdg.configHome} Config
        file:///mnt/rocket Rocket
      '';
    };
  };
}
