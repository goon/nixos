{
  config,
  lib,
  pkgs,
  ...
}:
lib.module config "nix" true {
  config = {
    nixpkgs.config.allowUnfree = true;

    documentation = {
      enable = false;
      man.enable = false;
    };

    nix = {
      channel.enable = false;
      gc.automatic = false;

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

      nix-ld.enable = true;
    };
  };

  homeManager = _: {
    home.packages = with pkgs; [
      nil
      nixd
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
