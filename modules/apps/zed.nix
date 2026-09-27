{
  config,
  lib,
  ...
}:
lib.module config "zed" false {
  homeManager = { globals, ... }: {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "toml"
        "lua"
        "nix"
        "qml"
      ];
      userSettings = {
        buffer_font_family = globals.userFonts.monospace;
        ui_font_family = globals.userFonts.sansSerif;

        agent.dock = "right";
        project_panel.dock = "left";
        cursor_animation.enabled = true;
        inline_code_actions = false;
        current_line_highlight = "none";

        git = {
          inline_blame.enabled = false;
          git_gutter = "hide";
        };

        gutter = {
          runnables = false;
          breakpoints = false;
          folds = false;
        };

        scrollbar = {
          git_diff = false;
          show = "never";
        };

        toolbar = {
          breadcrumbs = false;
          quick_actions = false;
        };
      };
    };
  };
}
