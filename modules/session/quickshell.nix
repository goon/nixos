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
    jq
    pywalfox-native
    imagemagick
  ];
in
lib.module config "quickshell" false {
  config = {
    module.screenshot = true;
    module.clipboard = true;
    module.monitors = true;

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
      xdg.configFile."yaks".source =
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
