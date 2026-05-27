{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  options.module.quickshell.enable = lib.mkEnableOption "Quickshell" // {
    default = true;
  };

  config = lib.mkIf config.module.quickshell.enable {
    environment.sessionVariables = {
      QS_ICON_THEME = "Papirus";
      QT_USE_PORTAL = "1";
    };

    home-manager.sharedModules = [
      (
        { config, osConfig, ... }:
        {
          xdg.configFile."quickshell".source =
            config.lib.file.mkOutOfStoreSymlink "${osConfig.globals.repoPath}/modules/session/quickshell";

          home.packages = with pkgs; [
            inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell
            gowall # Wallpaper Themer
            cava # Visualizer
          ];
        }
      )
    ];
  };
}
