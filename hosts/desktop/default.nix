{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  # ========== Modules (Dendritic Dashboard) ==========

  # [1] Hardware Support
  module.radeon.enable = true;

  # [2] Session (The Switch)
  module.desktop.windowmanager = "hyprland";

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
  # module.yazi.enable = false;

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
