{
  config,
  lib,
  inputs,
  ...
}:
lib.module config "craft" false {
  config = {
    imports = [ inputs.nix-craftapps.nixosModules.default ];
    programs.craftapps = {
      enable = true;
      apps.photocraft.enable = true;
      apps.vectorcraft.enable = true;
      apps.filmcraft.enable = true;
      apps.effectcraft.enable = true;
    };
  };
}
