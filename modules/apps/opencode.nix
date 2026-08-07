{
  config,
  lib,
  pkgs,
  ...
}:
lib.module config "opencode" false {
  homeManager = { lib, ... }: {
    home.packages = [
      pkgs.opencode
      pkgs.rtk
      pkgs.snip
      pkgs.mcp-nixos
    ];
    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      snapshot = false;
      default_agent = "plan";
      agent = {
        plan = {
          mode = "primary";
          model = "opencode-go/minimax-m3";
        };
        build = {
          mode = "primary";
          model = "opencode-go/deepseek-v4-pro";
        };
      };
      mcp = {
        nixos = {
          type = "local";
          command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
          enabled = true;
        };
        sequential-thinking = {
          type = "local";
          command = [ "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking" ];
          enabled = true;
        };
        memory = {
          type = "local";
          command = [ "${pkgs.mcp-server-memory}/bin/mcp-server-memory" ];
          enabled = true;
        };
      };
    };

    home.activation.rtkOpencode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export RTK_TELEMETRY_DISABLED=1
      ${pkgs.rtk}/bin/rtk init -g --opencode --auto-patch
    '';
  };
}
