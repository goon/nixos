{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  # ========== Modules (Dendritic Dashboard) ==========

  # [1] Hardware Support
  module.hardware.radeon.enable = true;

  # [2] Session (The Switch)
  module.desktop.windowmanager = "mangowm";

  # [3] Commons (Shared Plumbing - Enabled by default)
  # module.gtk.enable = false;
  # module.shell.enable = false;
  # module.utils.enable = false;
  # module.xdg.enable = false;

  # [4] Extra (Optional Features - Enabled by default)
  # module.creative.enable = false;
  # module.dev.enable = false;
  # module.fastfetch.enable = false;
  # module.firefox.enable = false;
  # module.flatpak.enable = false;
  # module.gaming.enable = false;
  # module.git.enable = false;
  # module.gnome.enable = false;
  # module.kitty.enable = false;
  # module.nixcord.enable = false;
  # module.nvf.enable = false;
  # module.obs.enable = false;
  # module.obsidian.enable = false;
  # module.opencode.enable = false;
  # module.quickshell.enable = false;
  # module.spicetify.enable = false;
  # module.whogle.enable = false;
  # module.yazi.enable = false;

  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/c6a3965a-5bf3-451c-934e-b391969c180a";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
    ];
  };

  system.stateVersion = "25.11";
}
