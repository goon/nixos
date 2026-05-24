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
    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          antigravity
          google-chrome
        ];
      }
    ];
  };
}
