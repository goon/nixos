{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "hyprland" true {
  config = {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
      ];
      configPackages = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
      ];
      config.hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };
  };

  userPkgs = with pkgs; [
    hyprpolkitagent
  ];

  home = { config, osConfig, ... }: {
    xdg.configFile."hypr".source =
      config.lib.file.mkOutOfStoreSymlink "${osConfig.globals.repo}/modules/session/hyprland";
  };
}
