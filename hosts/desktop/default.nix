{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  # ========== Modules (Dendritic Dashboard) ==========

  # [1] Hardware
  module.radeon.enable = true;

  # [2] Session
  module.wayland.enable = true;
  module.hyprland.enable = true;

  # [3] Extra (Optional Features)
  module.creative.enable = true;
  module.dev.enable = true;
  module.easyeffects.enable = true;
  module.fastfetch.enable = true;
  module.firefox.enable = true;
  module.flatpak.enable = true;
  module.gaming.enable = true;
  module.git.enable = true;
  module.gnome.enable = true;
  module.kitty.enable = true;
  module.localsend.enable = true;
  module.nixcord.enable = true;
  module.nvf.enable = true;
  module.obs.enable = true;
  module.obsidian.enable = true;
  module.opencode.enable = true;
  module.quickshell.enable = true;
  module.spicetify.enable = true;
  module.starship.enable = true;
  module.yazi.enable = true;

  fileSystems."/mnt/rocket" = {
    device = "/dev/disk/by-uuid/f6e17653-e430-487b-ac24-0c509fba3968";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
    ];
  };

  nix.settings = {
    max-jobs = 10;
    cores = 10;
  };

  globals.stateVersion = "25.11";
}
