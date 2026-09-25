{
  config,
  lib,
  inputs,
  ...
}:
lib.module config "sonora" false {
  homeManager = {
    imports = [ inputs.sonora.homeManagerModules.default ];
    programs.sonora.enable = true;
  };
}
