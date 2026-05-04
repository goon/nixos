{
  inputs,
  lib,
  config,
  ...
}:

{
  imports = [
    inputs.mangowm.nixosModules.mango
  ];

  config = lib.mkIf (config.module.desktop.windowmanager == "mangowm") {
    # Use the official NixOS module for system-level setup
    programs.mango.enable = true;

    home-manager.users.${config._module.args.username} =
      {
        config,
        osConfig,
        pkgs,
        ...
      }:
      {
        imports = [
          inputs.mangowm.hmModules.mango
        ];

        home.packages = with pkgs; [
          lswt
          wlrctl
          grim
          slurp
          swappy
        ];

        # Enable the HM module
        wayland.windowManager.mango.enable = true;

        # Maintain the repo's pattern of out-of-store symlinks for session configs
        xdg.configFile."mango".source =
          config.lib.file.mkOutOfStoreSymlink "${osConfig.globals.repoPath}/modules/session/mangowm";

        xdg.configFile."swappy/config".text = ''
          [Default]
          save_dir=${osConfig.globals.paths.home}/Pictures/Screenshots
          save_filename_format=swappy-%Y%m%d-%H%M%S.png
          show_panel=false
          line_size=5
          text_size=20
          text_font=sans-serif
          paint_mode=brush
          early_exit=true
          fill_shape=false
        '';
      };
  };
}
