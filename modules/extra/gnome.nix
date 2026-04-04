{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.gnome.enable = lib.mkEnableOption "GNOME Desktop Application Suite" // {
    default = true;
  };

  config = lib.mkIf config.module.gnome.enable {
    # ========== System Layer (NixOS) ==========
    services.devmon.enable = true;
    services.accounts-daemon.enable = true;

    # ========== User Layer (Home Manager) ==========
    home-manager.users.${config._module.args.username} = {
      home.packages = with pkgs; [
        gnome-music
        gnome-font-viewer
        totem # Videos
        loupe # Image Viewer
        evince # Document Viewer
        resources # System Monitor
        eyedropper # Color Picker
        nautilus
        sushi # File Preview
        ffmpegthumbnailer
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
