{ pkgs, inputs, ... }:

{
  services.dbus.enable = true;

  # Desktop Environment packages
  environment.systemPackages = with pkgs; [
    # Window Manager and related
    inputs.quickshell.packages.${pkgs.stdenv.system}.quickshell
    inputs.niri.packages.${pkgs.stdenv.system}.default
    xwayland-satellite

    # Wayland clipboard tools
    cliphist
    wl-clipboard
    libnotify
    # Desktop theming and utilities
    xdg-user-dirs
    glib # Contains gsettings command
    gtk3 # GTK3 schemas for gsettings
    qt6Packages.qt6ct # Qt6 theme configuration
  ];

  # Register Niri Wayland session for display manager
  services.displayManager.sessionPackages = [
    inputs.niri.packages.${pkgs.stdenv.system}.default
  ];

  # XDG Desktop Portal
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
}
