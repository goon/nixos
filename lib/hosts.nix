# lib/hosts.nix
# Dynamic host discovery engine.
# Scans a directory for subdirectories and maps them into nixosConfigurations automatically.

{ lib, inputs }:

lib.extend (
  final: _prev: {
    mkHosts =
      dir:
      {
        system,
        specialArgs,
        baseModules,
      }:
      let
        inherit (builtins) readDir;
        inherit (final) filterAttrs mapAttrs;

        dirs = readDir dir;
        hostDirs = filterAttrs (_n: v: v == "directory") dirs;
      in
      mapAttrs (
        hostName: _:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          inherit specialArgs;
          modules = baseModules ++ [ (dir + "/${hostName}") ];
        }
      ) hostDirs;
  }
)
