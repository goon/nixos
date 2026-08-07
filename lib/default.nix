# ── DEFAULT.NIX ──────────────
# Central entrypoint that binds all custom library extensions into a single object.
# Uses lib.extend to chain extensions so they can reference each other natively.
# This extended lib is what gets passed to modules and hosts.
{
  lib,
  inputs,
}:
let
  l1 = import ./module.nix { inherit lib; };
  l1' = l1 // (import ./overlays.nix { lib = l1; });
  l2 = import ./hosts.nix {
    lib = l1';
    inherit inputs;
  };
  l3 =
    l2
    // import ./outputs.nix {
      lib = l2;
      inherit inputs;
    };
in
l3
