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
    cava
    jq
    imagemagick
  ];
in
lib.module config "quickshell" false {
  config = {
    module.monitors = true;

    environment.sessionVariables = {
      QS_ICON_THEME = "Papirus";
      QT_USE_PORTAL = "1";
      QS_CONFIG_PATH = "${config.globals.repo}/modules/session/yaks";
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
          Description = "Yaks - Blazingly Mid Desktop Shell";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session-pre.target" ];
        };
        Service = {
          ExecStart = "${lib.getExe quickshell}";
          Environment = [
            "QT_USE_PORTAL=1"
            "QS_CONFIG_PATH=${globals.repo}/modules/session/yaks"
          ];
          Restart = "on-failure";
          RestartSec = "2";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
