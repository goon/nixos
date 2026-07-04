{
  config,
  lib,
  pkgs,
  ...
}:
lib.module config "nix" true {
  config = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = [ "pnpm-10.29.2" ];

    documentation = {
      enable = false;
      man.enable = false;
    };

    nix.channel.enable = false;

    nix = {
      settings = {
        use-xdg-base-directories = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        warn-dirty = false;
        substituters = [
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      gc.automatic = false;
    };

    programs = {
      nh = {
        enable = true;
        flake = config.globals.repo;
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
  };
}
