{ ... }:
{
  # ========== Imports ==========
  imports = [

  ];

  # ========== Host Identity ==========
  networking.hostName = "laptop";

  # ========== System Version ==========
  system.stateVersion = "25.11";

  # ========== TODO ==========
  # When ready to configure:
  # 1. Run 'nixos-generate-config' on laptop hardware
  # 2. Copy hardware-configuration.nix to this directory
  # 3. Add required imports from ../../modules/
  # 4. Add to flake.nix as nixosConfigurations.laptop
}
