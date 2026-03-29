_:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.auto-optimise-store = true;
  nix.settings.warn-dirty = false;
  # Binary caches (niri + garnix for affinity)
  nix.settings.substituters = [
    "https://niri.cachix.org"
    "https://cache.garnix.io"
  ];
  nix.settings.trusted-public-keys = [
    "niri.cachix.org-1:Wv0NxOcoZsSsIa5NbZaf1QjZbmhbNnsCf7cH8H1HGyc="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJPXNJQ="
  ];

  # Limit CPU usage for builds
  nix.settings.max-jobs = 10;
  nix.settings.cores = 10;

  nix.gc.automatic = false;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.dates = "weekly";
    clean.extraArgs = "--keep 3";
  };
}
