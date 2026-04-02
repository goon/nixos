{
  # ========== Imports ==========
  imports = [
    ./hardware-configuration.nix
    ../modules/desktop
    ../modules/home/home.nix
  ];

  # ========== Host Identity ==========
  networking.hostName = "desktop";

  # ========== Window Manager & Desktop Selection ==========
  desktop.windowmanager.name = "niri";
  desktop.gnome.enable = true;

  # ========== System Version ==========
  system.stateVersion = "25.11";
}
