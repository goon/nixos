{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "opencode" false {
  userPkgs = [
    pkgs.opencode
    pkgs.mcp-nixos
  ];

  home = {
    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      snapshot = false;
      default_agent = "plan";
      agent = {
        plan = {
          mode = "primary";
          model = "opencode-go/glm-5.1";
        };
        build = {
          mode = "primary";
          model = "opencode-go/deepseek-v4-flash";
        };
      };
      mcp = {
        nixos = {
          type = "local";
          command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
          enabled = true;
        };
      };
    };
  };
}
