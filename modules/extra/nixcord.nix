{
  config,
  lib,
  inputs,
  ...
}:

{
  options.module.nixcord.enable = lib.mkEnableOption "Nixcord (Declarative Discord)" // {
    default = true;
  };

  config = lib.mkIf config.module.nixcord.enable {
    home-manager.sharedModules = [
      {
        imports = [ inputs.nixcord.homeModules.nixcord ];

        programs.nixcord = {
          enable = true;
          discord.enable = false;
          vesktop.enable = true;
          config = {
            useQuickCss = true;
            transparent = true;
            themeLinks = [ ];
            enabledThemes = [ "qsTheme.css" ];
            plugins = {
              alwaysAnimate.enable = true;
              imageZoom.enable = true;
            };
          };
        };
      }
    ];
  };
}
