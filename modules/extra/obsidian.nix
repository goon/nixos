{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.obsidian.enable = lib.mkEnableOption "Obsidian Note-taking App" // {
    default = true;
  };

  config = lib.mkIf config.module.obsidian.enable {
    home-manager.users.${config._module.args.username} = {
      home.packages = [ pkgs.obsidian ];
    };
  };
}
