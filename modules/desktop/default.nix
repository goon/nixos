{ ... }:

{
  # ========== Desktop Specific Imports ==========
  imports = [
    ./desktop.nix
    ./gnome.nix
    ./flatpak.nix
    ./fonts.nix
    ./gaming.nix
    ./packages.nix
    ./wm
    ../core/audio.nix
    ../core/greeter.nix
    ../core/peripherals.nix
  ];

  programs.dconf.enable = true;
}
