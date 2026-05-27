{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
in
{
  options.module.gtk.enable =
    mkEnableOption "GTK Environment (Themes, Icons, Cursors, Bookmarks)"
    // {
      default = true;
    };

  config = mkIf config.module.gtk.enable {
    # ========== System Layer (NixOS) ==========
    services.dbus.enable = true;
    programs.dconf.enable = true;

    environment.sessionVariables = {
      QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
    };

    # User-facing features

    # ========== User Layer (Home Manager) ==========
    home-manager.sharedModules = [
      {
        dconf.enable = true;

        home.packages = with pkgs; [
          # Theming
          adw-gtk3
          papirus-icon-theme
          bibata-cursors
          glib
          gtk3
        ];

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
            font-name = "${config.globals.userFonts.sansSerif} 11";
            document-font-name = "${config.globals.userFonts.sansSerif} 11";
            monospace-font-name = "${config.globals.userFonts.monospace} 11";
            gtk-theme = "adw-gtk3";
            icon-theme = "Papirus";
          };
        };

        # GTK Bookmarks
        xdg.configFile."gtk-3.0/bookmarks" = {
          force = true;
          text = ''
            file://${config.globals.repoPath} Nix
            file://${config.globals.paths.home}/Downloads Downloads
            file://${config.globals.paths.home}/Documents Documents
            file://${config.globals.paths.home}/Pictures Pictures
            file://${config.globals.paths.home}/Music Music
            file://${config.globals.paths.home}/Videos Videos
            file://${config.globals.paths.config} Config
          '';
        };
      }
    ];
  };
}
