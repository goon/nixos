{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
lib.module config "affinity" false {
  config = {
    nixpkgs.overlays = [ inputs.affinity-nix.overlays.default ];
  };

  homeManager = _: {
    home.packages = [
      pkgs.affinity-v3
    ];
  };
}
