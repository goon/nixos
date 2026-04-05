{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.dev.enable = lib.mkEnableOption "Development Runtimes" // {
    default = true;
  };

  config = lib.mkIf config.module.dev.enable {
    home-manager.users.${config._module.args.username} = {
      home.packages = with pkgs; [
        nodejs
        python3
        go
      ];
    };
  };
}
