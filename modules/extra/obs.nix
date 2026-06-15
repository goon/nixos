{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "obs" true {
    home-manager.sharedModules = [
      {
        programs.obs-studio = {
          enable = true;
          plugins = with pkgs.obs-studio-plugins; [
            wlrobs
            obs-vaapi
            obs-pipewire-audio-capture
          ];
        };
      }
    ];}