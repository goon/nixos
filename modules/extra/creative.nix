{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

lib.module config "creative" true {
    nixpkgs.overlays = [ inputs.affinity-nix.overlays.default ];

    home-manager.sharedModules = [
      {
        home.packages = [
          pkgs.affinity-v3
        ];
      }
    ];}