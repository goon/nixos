{ username, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.auto-optimise-store = true;
  nix.settings.warn-dirty = false;
  # Binary Caches ( Niri & Affinity )
  nix.settings.substituters = [
    "https://niri.cachix.org"
    "https://cache.garnix.io"
  ];
  nix.settings.trusted-public-keys = [
    "niri.cachix.org-1:Wv0NxOcoZsSsIa5NbZaf1QjZbmhbNnsCf7cH8H1HGyc="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJPXNJQ="
  ];

  # CPU Limits for Builds
  nix.settings.max-jobs = 10;
  nix.settings.cores = 10;

  nix.gc.automatic = false;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.dates = "weekly";
    clean.extraArgs = "--keep 5";
  };

  home-manager.users.${username} = {
    home.shellAliases = {
      nhs = "nh os switch";
      nht = "nh os test";
      nhc = "nh clean all --keep 8";
      nhu = "nh os switch -u";
    };
  };

  # Enable nix-ld for unpatched binaries (e.g., Playwright/Chrome drivers)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
  ];
}
