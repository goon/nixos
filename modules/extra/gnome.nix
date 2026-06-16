{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "gnome" false {
  config = {
    services = {
      devmon.enable = true;
      accounts-daemon.enable = true;
      gnome = {
        tinysparql.enable = true;
        localsearch.enable = true;
      };
    };
  };

  userPkgs = with pkgs; [
    nautilus
    sushi
    ffmpegthumbnailer
    totem
    loupe
    decibels
    fragments
    switcheroo
  ];

  home = {
    dconf.settings = {
      "org/gnome/nautilus/preferences" = {
        show-hidden-files = true;
        default-folder-viewer = "list-view";
        show-delete-permanently = true;
      };
    };
  };
}
