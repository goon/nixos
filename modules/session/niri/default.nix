{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:

{
  config = lib.mkIf (config.module.desktop.windowmanager == "niri") {
    # System-level Niri integration
    programs.niri = {
      enable = true;
      package = inputs.niri.packages.${pkgs.stdenv.system}.default;
    };

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

    # Explicit session and portal configuration (redundant with programs.niri but kept for clarity)
    services.displayManager.sessionPackages = [
      inputs.niri.packages.${pkgs.stdenv.system}.default
    ];

    xdg.portal = {
      enable = true;
      configPackages = [
        inputs.niri.packages.${pkgs.stdenv.system}.default
      ];
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];
    };
  };
}


