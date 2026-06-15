{
  config,
  lib,
  ...
}:

lib.module config "qt" true {
    environment.sessionVariables = {
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_SCALE_FACTOR = "1";
      QT_FONT_DPI = "96";
    };

    home-manager.sharedModules = [
      {
        qt = {
          enable = true;
          platformTheme.name = "adwaita";
          style.name = "adwaita-dark";
        };
      }
    ];}