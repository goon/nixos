{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "sandbox";

  # ========== Modules (Dendritic Dashboard) ==========

  # [1] Hardware
  module.virtualisation.enable = true;

  # [2] Session
  module.wayland.enable = true;
  module.hyprland.enable = true;

  # [3] Apps (Optional Features)
  module.dev.enable = true;
  module.fastfetch.enable = true;
  module.firefox.enable = true;
  module.git.enable = true;
  module.kitty.enable = true;
  module.nvf.enable = true;
  module.starship.enable = true;

  nix.settings = {
    max-jobs = 4;
    cores = 4;
  };

  globals.stateVersion = "25.11";
}
