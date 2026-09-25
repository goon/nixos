{
  config,
  lib,
  ...
}:
lib.module config "zed" false {
  homeManager = { globals, ... }: {
    programs.zed-editor = {
      enable = true;
      userSettings = {
        buffer_font_family = globals.userFonts.monospace;
        ui_font_family = globals.userFonts.sansSerif;
        current_line_highlight = "none";
        agent.dock = "right";
        project_panel.dock = "left";
      };
    };
  };
}
