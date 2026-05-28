{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.qt.enable = lib.mkEnableOption "Qt Environment" // {
    default = true;
  };

  config = lib.mkIf config.module.qt.enable {
    environment.sessionVariables = {
      QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_SCALE_FACTOR = "1";
      QT_FONT_DPI = "96";
    };

    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          qt6Packages.qt6ct
        ];
      }
    ];
  };
}
