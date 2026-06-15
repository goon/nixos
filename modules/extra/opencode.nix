{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "opencode" true {
  userPkgs = [ pkgs.opencode ];

  home = {
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
          model = "opencode-go/deepseek-v4-flash";
        };
      };
    };
  };
}
