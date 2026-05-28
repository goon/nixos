{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.dev.enable = lib.mkEnableOption "Development Runtimes" // {
    default = true;
  };

  config = lib.mkIf config.module.dev.enable {
    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          nodejs
          python3
          go
        ];

        programs.vscodium = {
          enable = true;
          profiles.default = {
            extensions = with pkgs.vscode-extensions; [
              jnoortheen.nix-ide
              pkief.material-icon-theme
            ];
            userSettings = {
              "window.titleBarStyle" = "custom";
              "window.customTitleBarVisibility" = "never";
              "window.menuBarVisibility" = "hidden";
              "editor.fontFamily" = "'${config.globals.userFonts.monospace}', 'monospace'";
              "workbench.statusBar.visible" = false;
              "editor.minimap.enabled" = false;
              "workbench.iconTheme" = "material-icon-theme";
            };
          };
        };
      }
    ];
  };
}
