{
  username,
  pkgs,
  config,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      warn-dirty = false;
      # Binary Caches ( Niri & Affinity )
      substituters = [
        "https://niri.cachix.org"
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "niri.cachix.org-1:Wv0NxOcoZsSsIa5NbZaf1QjZbmhbNnsCf7cH8H1HGyc="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJPXNJQ="
      ];

      # CPU Limits for Builds
      max-jobs = 10;
      cores = 10;
    };

    gc.automatic = false;
  };

  programs = {
    nh = {
      enable = true;
      flake = config.globals.repoPath;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 5";
      };
    };

    # Enable nix-ld for unpatched binaries (e.g., Playwright/Chrome drivers)
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        fuse3
        icu
        nss
        openssl
        curl
        expat
      ];
    };
  };

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      statix
      deadnix
    ];
    home.shellAliases = {
      nhs = "nh os switch";
      nht = "nh os test";
      nhc = "nh clean all --keep 8";
      nhu = "nh os switch -u";
    };
  };
}
