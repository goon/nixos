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
      { config, osConfig, pkgs, ... }:
      {
        imports = [
          inputs.mangowm.hmModules.mango
        ];

        home.packages = [ pkgs.lswt pkgs.wlrctl ];

        # Enable the HM module
        wayland.windowManager.mango.enable = true;

        # Maintain the repo's pattern of out-of-store symlinks for session configs
        xdg.configFile."mango".source =
          config.lib.file.mkOutOfStoreSymlink "${osConfig.globals.repoPath}/modules/session/mangowm";
      };
  };
}
