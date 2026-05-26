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
    };

    home-manager.sharedModules = [
      (
        { config, osConfig, ... }:
        {
          xdg.configFile."quickshell".source =
            config.lib.file.mkOutOfStoreSymlink "${osConfig.globals.repoPath}/modules/session/quickshell";

          home.packages = with pkgs; [
            inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell
            qt6Packages.qt6ct
            gowall # Wallpaper Themer
            cava # Visualizer
          ];
        }
      )
    ];
  };
}
