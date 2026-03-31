{ pkgs, inputs, ... }:

{
  services.dbus.enable = true;

  # Desktop Environment packages
  environment.systemPackages = with pkgs; [
    # Window Manager related
    inputs.quickshell.packages.${pkgs.stdenv.system}.quickshell

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
}
