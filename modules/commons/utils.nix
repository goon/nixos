{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.utils.enable = lib.mkEnableOption "Core CLI Utilities (fd, ripgrep, wget, etc.)" // {
    default = true;
  };

  config = lib.mkIf config.module.utils.enable {
    home-manager.users.${config._module.args.username} = {
      home.packages = with pkgs; [
        fd
        ripgrep
        wget
        curl
        unzip
      ];
    };
  };
}
