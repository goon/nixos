{
  imports = [
    ./hardware-configuration.nix
  ];

  module.hyprland = true;

  module.radeon = true;
  module.monitors = true;
  module.logitech = true;
  module.wooting = true;

  module.affinity = true;
  module.dev = true;
  module.easyeffects = true;
  module.fastfetch = true;
  module.firefox = true;
  module.flatpak = true;
  module.gaming = true;
  module.git = true;
  module.gnome = true;
  module.kitty = true;
  module.localsend = true;
  module.nixcord = true;
  module.nvf = true;
  module.obsidian = true;
  module.opencode = true;
  module.spicetify = true;
  module.starship = true;
  module.yazi = true;

  networking.hostName = "desktop";

  fileSystems."/mnt/rocket" = {
    device = "/dev/disk/by-uuid/f6e17653-e430-487b-ac24-0c509fba3968";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
      "x-gvfs-show"
    ];
  };

  nix.settings = {
    max-jobs = 10;
    cores = 10;
  };

  globals.stateVersion = "25.11";
}
