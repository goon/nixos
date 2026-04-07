{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:

{
  config = lib.mkIf (config.module.desktop.windowmanager == "niri") {
    home-manager.users.${config._module.args.username} =
      { config, osConfig, ... }:
      {
        xdg.configFile."niri".source =
          config.lib.file.mkOutOfStoreSymlink "${osConfig.globals.repoPath}/modules/session/niri";

        home.packages = with pkgs; [
          inputs.niri.packages.${pkgs.stdenv.system}.default
          xwayland-satellite
        ];
      };

    services.displayManager.sessionPackages = [
      inputs.niri.packages.${pkgs.stdenv.system}.default
    ];

    xdg.portal = {
      enable = true;
      config.common.default = [ "gtk" ];
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];
      configPackages = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];
    };
  };
}
