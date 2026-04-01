{ ... }:
{
  # ========== Imports ==========
  imports = [
    ./hardware-configuration.nix
    ../modules/desktop
    ../modules/home/home.nix
  ];

  # ========== Host Identity ==========
  networking.hostName = "desktop";

  # ========== Window Manager Selection ==========
  desktop.windowmanager.name = "niri";

  # ========== System Version ==========
  system.stateVersion = "25.11";
}
