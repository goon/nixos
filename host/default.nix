{
  imports = [
    ./hardware-configuration.nix
    ../modules/desktop
    ../modules/home/home.nix
  ];

  networking.hostName = "desktop";

  desktop.windowmanager.name = "niri";
  desktop.gnome.enable = true;

  system.stateVersion = "25.11";
}
