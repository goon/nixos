{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "sandbox";

  # ========== Modules (Dendritic Dashboard) ==========

  # [1] Hardware Support
  # module.radeon.enable = false; 

  # [2] Session (The Switch)
  module.desktop.windowmanager = "mango";

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

  # ========== Virtualisation ==========

  virtualisation.vmware.guest.enable = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  nix.settings = {
    max-jobs = 2;
    cores = 2;
  };

  system.stateVersion = "25.11";
}
