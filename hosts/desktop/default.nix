{ ... }:
{
  # ========== Imports ==========
  imports = [
    ./hardware-configuration.nix

    # ========== Core ==========
    ../../modules/core/audio.nix
    ../../modules/core/boot.nix
    ../../modules/core/filesystems.nix
    ../../modules/core/greeter.nix
    ../../modules/core/hardware.nix
    ../../modules/core/locale.nix
    ../../modules/core/peripherals.nix
    ../../modules/core/networking.nix
    ../../modules/core/nix.nix
    ../../modules/core/power.nix
    ../../modules/core/security.nix
    ../../modules/core/user.nix

    # ========== Desktop ==========
    ../../modules/desktop/desktop.nix
    ../../modules/desktop/flatpak.nix
    ../../modules/desktop/fonts.nix
    ../../modules/desktop/gaming.nix
    ../../modules/desktop/packages.nix

    # ========== Home ==========
    ../../modules/home/home.nix
  ];

  # ========== Host Identity ==========
  networking.hostName = "desktop";

  # ========== System Version ==========
  system.stateVersion = "25.11";
}
