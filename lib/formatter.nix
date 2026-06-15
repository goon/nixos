# lib/formatter.nix
# Configuration for treefmt-nix.
# Defines the formatters used by 'nix fmt' and 'nix flake check'.

{
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    deadnix.enable = true;
    statix.enable = true;
  };
}
