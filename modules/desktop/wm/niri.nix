{ pkgs, inputs, lib, config, ... }:

let
  cfg = config.desktop.wm;
in
{
  config = lib.mkIf (cfg.name == "niri") {
    environment.systemPackages = with pkgs; [
      inputs.niri.packages.${pkgs.stdenv.system}.default
      xwayland-satellite
    ];

    services.displayManager.sessionPackages = [
      inputs.niri.packages.${pkgs.stdenv.system}.default
    ];

    xdg.portal = {
      enable = true;
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
