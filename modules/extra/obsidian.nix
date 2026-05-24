{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.obsidian.enable = lib.mkEnableOption "Obsidian" // {
    default = true;
  };

  config = lib.mkIf config.module.obsidian.enable {
    home-manager.sharedModules = [
      {
        home.packages = [ pkgs.obsidian ];
      }
    ];
  };
}
