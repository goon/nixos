{
  pkgs,
  lib,
  config,
  ...
}:

{
  config = lib.mkIf (config.module.desktop.windowmanager == "hyprland") {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    home-manager.users.${config._module.args.username} =
      { config, osConfig, ... }:
      {
        xdg.configFile."hypr".source =
          config.lib.file.mkOutOfStoreSymlink "${osConfig.globals.repoPath}/modules/session/hyprland";

        home.packages = with pkgs; [
          hyprpolkitagent
          grim
          slurp
        ];
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
    };
  };
}
