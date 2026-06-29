{
  config,
  lib,
  ...
}:
lib.module config "qt" false {
  config = {
    environment.sessionVariables = {
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_SCALE_FACTOR = "1";
      QT_FONT_DPI = "96";
    };
  };

  homeManager = {
    qt = {
      enable = true;
      platformTheme.name = "gtk3";
      style.name = "kvantum";
    };

    xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=quickshell
    '';

    xdg.desktopEntries.kvantummanager = {
      name = "Kvantum Manager";
      noDisplay = true;
    };
  };
}
