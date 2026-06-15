# lib/options.nix
# Utility wrappers around standard NixOS mkOption declarations.
# Provides shorthand 'opt' and 'boolOpt' functions to reduce boilerplate.

{ lib }:

lib.extend (
  final: _prev: {
    opt =
      type: default: description:
      final.mkOption {
        inherit type default description;
      };

    boolOpt =
      default: description:
      final.mkOption {
        inherit default description;
        type = final.types.bool;
      };
  }
)
