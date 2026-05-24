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
        ];

        wayland.windowManager.mango.enable = true;

        xdg.configFile."mango".source =
          config.lib.file.mkOutOfStoreSymlink "${osConfig.globals.repoPath}/modules/session/mango";
      };
  };
}
