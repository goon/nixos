{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.proton.enable = lib.mkEnableOption "Proton Applications" // {
    default = true;
  };

  config = lib.mkIf config.module.proton.enable {
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
