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
    services = {
      devmon.enable = true;
      accounts-daemon.enable = true;
      gnome = {
        tinysparql.enable = true;
        localsearch.enable = true;
      };
    };

    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          nautilus
          sushi
          ffmpegthumbnailer
          totem
          loupe
          decibels
          fragments
          switcheroo
        ];

        dconf.settings = {
          "org/gnome/nautilus/preferences" = {
            show-hidden-files = true;
            default-folder-viewer = "list-view";
            show-delete-permanently = true;
          };
        };
      }
    ];
  };
}
