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
      }
    ];
  };
}
