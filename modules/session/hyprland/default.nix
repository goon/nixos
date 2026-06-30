{
  config,
  lib,
  pkgs,
  ...
}:
lib.module config "hyprland" false {

  includes = [
    "wayland"
  ];

  config = {
    programs.hyprland = {
      enable = true;
    };
  };

  homeManager =
    {
      config,
      globals,
      ...
    }:
    {
      home.packages = with pkgs; [
        hyprpolkitagent
      ];
      systemd.user.targets.hyprland-session = {
        Unit = {
          Description = "Hyprland compositor session";
          Documentation = "man:systemd.special(7)";
          BindsTo = [ "graphical-session.target" ];
          Wants = [ "graphical-session-pre.target" ];
          After = [ "graphical-session-pre.target" ];
        };
      };

      xdg.configFile."hypr".source =
        config.lib.file.mkOutOfStoreSymlink "${globals.repo}/modules/session/hyprland";
    };
}
