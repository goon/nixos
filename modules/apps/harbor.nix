{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  harbor = inputs.harbor.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
lib.module config "harbor" false {
  homeManager = _: { home.packages = [ harbor ]; };
}
