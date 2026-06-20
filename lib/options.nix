# lib/options.nix
# Utility wrappers around standard NixOS mkOption declarations.
# Provides shorthand 'opt' and 'boolOpt' functions to reduce boilerplate.

{ lib }:

lib.extend (
  final: _prev: {
    opt =
      type: default:
      final.mkOption {
        inherit type default;
      };

    boolOpt =
      default:
      final.mkOption {
        inherit default;
        type = final.types.bool;
      };
  }
)
