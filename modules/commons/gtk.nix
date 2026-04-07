{
  config,
  lib,
  pkgs,
  username,
  repoName,
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
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
    };

    # User-facing features

    # ========== User Layer (Home Manager) ==========
    home-manager.users.${username} = {
      imports = [ ];

      dconf.enable = true;

      home.packages = with pkgs; [
        # Theming
        adw-gtk3
        papirus-icon-theme
        bibata-cursors
        glib
        gtk3
      ];

      # Interface Theming
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          font-name = "${config.globals.userFonts.sansSerif} 10";
          document-font-name = "${config.globals.userFonts.sansSerif} 10";
          monospace-font-name = "${config.globals.userFonts.monospace} 10";
          gtk-theme = "adw-gtk3";
          icon-theme = "Papirus";
          cursor-theme = "Bibata-Modern-Classic";
        };
      };

      # GTK Bookmarks
      xdg.configFile."gtk-3.0/bookmarks" = {
        force = true;
        text = ''
          file:///home/${username}/${repoName} Nix
          file:///home/${username}/Downloads Downloads
          file:///home/${username}/Documents Documents
          file:///home/${username}/Pictures Pictures
          file:///home/${username}/Music Music
          file:///home/${username}/Videos Videos
          file:///home/${username}/.config Config
        '';
      };

    };
  };
}
