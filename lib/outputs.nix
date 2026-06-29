# ── OUTPUTS.NIX ──────────────
# The main evaluation engine for the flake.
# Bootstraps the recursive module tree, applies base system overlays
# and generates all flake outputs.

{
  lib,
  inputs,
  ...
}:
{
  mkOutputs =
    {
      self,
      nixpkgs,
      systems ? [ "x86_64-linux" ],
    }:
    let
      tree = import ./recursive.nix ../modules;

      baseModules = [
        ./includes.nix
        ({ config, ... }: {
          home-manager.extraSpecialArgs = {
            inherit inputs;
            inherit (config) globals;
          };
        })
        inputs.home-manager.nixosModules.default
        inputs.nix-flatpak.nixosModules.nix-flatpak
      ]
      ++ tree;
    in
    {
      nixosConfigurations = lib.mkHosts ../hosts {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs lib;
        };
        inherit baseModules;
      };

      formatter = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (inputs) treefmt-nix;
        in
        (treefmt-nix.lib.evalModule pkgs ./formatter.nix).config.build.wrapper
      );

      checks = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (inputs) treefmt-nix;
        in
        {
          formatting = (treefmt-nix.lib.evalModule pkgs ./formatter.nix).config.build.check self;
        }
      );
    };
}
