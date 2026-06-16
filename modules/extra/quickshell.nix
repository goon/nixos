{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;

  dependencies = with pkgs; [
    gowall
    cava
    brightnessctl
    ddcutil
    wl-clipboard
    cliphist
    jq
    pywalfox-native
  ];
in
lib.module config "quickshell" true {
  config = {
    environment.sessionVariables = {
      QS_ICON_THEME = "Papirus";
      QT_USE_PORTAL = "1";
    };
  };

  userPkgs = [ quickshell ] ++ dependencies;

  home = { config, osConfig, ... }: {
    xdg.configFile."quickshell".source =
      config.lib.file.mkOutOfStoreSymlink "${osConfig.globals.repo}/modules/session/quickshell";
  };
}
