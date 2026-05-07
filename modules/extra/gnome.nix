{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.gnome.enable = lib.mkEnableOption "GNOME" // {
    default = true;
  };

  config = lib.mkIf config.module.gnome.enable {
    # ========== System Layer (NixOS) ==========
    services.devmon.enable = true;
    services.accounts-daemon.enable = true;
    services.gnome.tinysparql.enable = true;
    services.gnome.localsearch.enable = true;

    # ========== User Layer (Home Manager) ==========
    home-manager.users.${config._module.args.username} = {
      home.packages = with pkgs; [
        gnome-music
        gnome-font-viewer
        totem # Videos
        loupe # Image Viewer
        evince # Document Viewer
        eyedropper # Color Picker
        decibels # Audio Player
        nautilus # File Explorer
        sushi # File Preview
        ffmpegthumbnailer
        gnome-disk-utility
      ];

      dconf.settings = {
        "org/gnome/nautilus/preferences" = {
          show-hidden-files = true;
          default-folder-viewer = "list-view";
          show-delete-permanently = true;
        };
      };
    };
  };
}
