# lib/default.nix
# Central entrypoint that binds all custom library extensions into a single object.
# Uses lib.extend to chain extensions so they can reference each other.

{ lib, inputs }:

let
  l1 = import ./module.nix { inherit lib; };
  l2 = import ./options.nix { lib = l1; };
  l3 = import ./hosts.nix {
    lib = l2;
    inherit inputs;
  };
in
l3
