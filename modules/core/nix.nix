{
  config,
  pkgs,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  documentation = {
    enable = false;
    man.enable = false;
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      warn-dirty = false;
      substituters = [
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
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

  home-manager.sharedModules = [
    {
      home.shellAliases = {
        nhs = "nh os switch";
        nht = "nh os test";
        nhc = "nh clean all --keep 8";
        nhu = "nh os switch -u";
        nhb = "nh os boot";
        nps = "nix search nixpkgs";
      };
    }
  ];
}
