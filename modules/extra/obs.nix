{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.obs.enable = lib.mkEnableOption "OBS" // {
    default = true;
  };

  config = lib.mkIf config.module.obs.enable {
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
    ];
  };
}
