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
lib.module config "quickshell" false {
  config = {
    environment.sessionVariables = {
      QS_ICON_THEME = "Papirus";
      QT_USE_PORTAL = "1";
    };
  };

  homeManager =
    {
      config,
      globals,
      ...
    }:
    {
      home.packages = [ quickshell ] ++ dependencies;
      xdg.configFile."quickshell".source =
        config.lib.file.mkOutOfStoreSymlink "${globals.repo}/modules/session/yaks";

      systemd.user.services.yaks = {
        Unit = {
          Description = "Quickshell Desktop Shell";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session-pre.target" ];
        };
        Service = {
          ExecStart = "${lib.getExe quickshell}";
          Environment = "QT_USE_PORTAL=1";
          Restart = "on-failure";
          RestartSec = "2";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
