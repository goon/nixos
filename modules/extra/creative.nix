{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

lib.module config "creative" true {
  config = {
    nixpkgs.overlays = [ inputs.affinity-nix.overlays.default ];
  };

  userPkgs = [
    pkgs.affinity-v3
  ];
}
