{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.module.proton;
in
{
  options.module.proton.enable = lib.mkEnableOption "Proton Applications" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages = [
          pkgs.protonmail-desktop
          pkgs.proton-pass
          pkgs.proton-vpn
        ];
      }
    ];
  };
}
