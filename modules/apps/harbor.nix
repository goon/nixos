{
  config,
  lib,
  pkgs,
  ...
}:
lib.module config "harbor" false {
  homeManager = _: {
    home.packages = [ (pkgs.callPackage ../../pkgs/harbor.nix { }) ];
  };
}
