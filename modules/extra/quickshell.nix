{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

lib.module config "quickshell" true {
  config = {
    environment.sessionVariables = {
      QS_ICON_THEME = "Papirus";
      QT_USE_PORTAL = "1";
    };
  };

  userPkgs = with pkgs; [
    inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell
    gowall # Wallpaper Themer
    cava # Visualizer
  ];

  home = { config, osConfig, ... }: {
    xdg.configFile."quickshell".source =
      config.lib.file.mkOutOfStoreSymlink "${osConfig.globals.repo}/modules/session/quickshell";
  };
}
