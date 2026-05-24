{
  pkgs,
  lib,
  config,
  ...
}:

{
  config = lib.mkIf (config.module.desktop.windowmanager == "hyprland") {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    home-manager.users.${config._module.args.username} =
      { config, osConfig, ... }:
      {
        xdg.configFile."hypr".source =
          config.lib.file.mkOutOfStoreSymlink "${osConfig.globals.repoPath}/modules/session/hyprland";

        home.packages = with pkgs; [
          hyprpolkitagent
          grim
          slurp
          swappy
          jq
        ];

        xdg.configFile."swappy/config".text = ''
          [Default]
          save_dir=${osConfig.globals.paths.home}/Pictures/Screenshots
          save_filename_format=%Y%m%d_%H%M%S.png
          show_panel=false
          line_size=5
          text_size=20
          text_font=sans-serif
          paint_mode=brush
          early_exit=true
          fill_shape=false
        '';
      };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
      ];
      configPackages = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
      ];
      config.hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };
  };
}
