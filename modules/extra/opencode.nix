{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.opencode.enable = lib.mkEnableOption "OpenCode AI Hub" // {
    default = true;
  };

  config = lib.mkIf config.module.opencode.enable {
    home-manager.users.${config._module.args.username} = {
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
            model = "opencode-go/kimi-k2.5";
          };
        };
      };
    };
  };
}
