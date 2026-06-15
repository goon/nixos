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
        inherit (builtins) readDir pathExists;
        inherit (final) filterAttrs mapAttrs;

        dirs = readDir dir;
        hostDirs = filterAttrs (_n: v: v == "directory") dirs;

        varsPath = dir + "/vars.nix";
        vars = if pathExists varsPath then import varsPath else { };
      in
      mapAttrs (
        hostName: _:
        let
          hostVars = vars.${hostName} or { };
        in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = specialArgs // hostVars;
          modules = baseModules ++ [ (dir + "/${hostName}") ];
        }
      ) hostDirs;
  }
)
