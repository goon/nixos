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

  config = lib.mkIf (config.module.desktop.windowmanager == "mango") {
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

        wayland.windowManager.mango.enable = true;

        xdg.configFile."mango".source =
          config.lib.file.mkOutOfStoreSymlink "${osConfig.globals.repoPath}/modules/session/mango";

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
