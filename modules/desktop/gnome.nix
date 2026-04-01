{
  pkgs,
  lib,
  config,
  user,
  repoName,
  ...
}:

{
  options.desktop.gnome = {
    enable = lib.mkEnableOption "Minimal GNOME application support";
  };

  config = lib.mkIf config.desktop.gnome.enable {
    # This module provides standalone GNOME application support.
    # We rely on core modules (core/filesystems.nix, core/power.nix, etc.) 
    # for shared services like gvfs, udisks2, upower, and localsearch (tracker).

    # Unique services needed for GNOME app integration
    services.devmon.enable = true; # Device monitoring
    services.accounts-daemon.enable = true; # User accounts and session info

    # ========== Home Manager Configuration ==========
    # Consolidates user-level settings and applications for GNOME apps
    home-manager.users.${user} = {
      home.packages = with pkgs; [
        # Applications
        gnome-music
        gnome-font-viewer
        totem # GNOME Videos
        loupe # GNOME Image Viewer
        evince # Document Viewer

        # GNOME Circle
        resources # System Monitor
        eyedropper # Color Picker
        
        # Nautilus & Utilities
        nautilus
        sushi # File Preview
        ffmpegthumbnailer # Thumbnails
      ];

      dconf.settings = {
        "org/gnome/nautilus/preferences" = {
          show-hidden-files = true;
          default-folder-viewer = "list-view";
          show-delete-permanently = true;
        };
      };

      # GTK Bookmarks
      xdg.configFile."gtk-3.0/bookmarks" = {
        force = true;
        text = ''
          file:///home/${user}/${repoName} Nix
          file:///home/${user}/Downloads Downloads
          file:///home/${user}/Documents Documents
          file:///home/${user}/Pictures Pictures
          file:///home/${user}/Music Music
          file:///home/${user}/Videos Videos
        '';
      };
    };
  };
}
