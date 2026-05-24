{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.utils.enable = lib.mkEnableOption "CLI Utilities" // {
    default = true;
  };

  config = lib.mkIf config.module.utils.enable {
    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          fd
          ripgrep
          wget
          curl
          unzip
          btop
          jq
        ];
      }
    ];
  };
}
