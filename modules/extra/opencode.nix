{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.opencode.enable = lib.mkEnableOption "Opencode" // {
    default = true;
  };

  config = lib.mkIf config.module.opencode.enable {
    home-manager.sharedModules = [
      {
        home.packages = [ pkgs.opencode ];

        xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
          "$schema" = "https://opencode.ai/config.json";
          snapshot = false;
          default_agent = "plan";
          agent = {
            plan = {
              mode = "primary";
              model = "opencode-go/glm-5";
            };
            build = {
              mode = "primary";
              model = "opencode-go/minimax-m2.5";
            };
          };
        };
      }
    ];
  };
}
