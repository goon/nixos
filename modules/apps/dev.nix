{
  config,
  lib,
  pkgs,
  ...
}:
lib.module config "dev" false {
  homeManager = {
    home.packages = with pkgs; [
      nixd
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
