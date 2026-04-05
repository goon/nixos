{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.whogle.enable = lib.mkEnableOption "Whogle Google" // {
    default = true;
  };

  config = lib.mkIf config.module.whogle.enable {
    home-manager.users.${config._module.args.username} = {
      home.packages = with pkgs; [
        antigravity
        google-chrome
      ];
    };
  };
}
