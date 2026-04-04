{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.obs.enable = lib.mkEnableOption "OBS Studio" // {
    default = true;
  };

  config = lib.mkIf config.module.obs.enable {
    home-manager.users.${config._module.args.username} = {
      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-vaapi
          obs-pipewire-audio-capture
        ];
      };
    };
  };
}
