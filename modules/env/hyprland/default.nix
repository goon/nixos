{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "hyprland" false {
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
    systemd.user.targets.hyprland-session = {
      Unit = {
        Description = "Hyprland compositor session";
        Documentation = "man:systemd.special(7)";
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };

    xdg.configFile."hypr".source =
      config.lib.file.mkOutOfStoreSymlink "${osConfig.globals.repo}/modules/env/hyprland";
  };
}
