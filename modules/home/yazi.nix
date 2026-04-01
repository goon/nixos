{ pkgs, ... }:

{
  home.packages = [ pkgs.trash-cli ];

  programs.yazi = {
    enable = true;
    shellWrapperName = "y";

    # ----- Main Settings (yazi.toml)
    settings = {
      mgr = {
        ratio = [ 2 4 3 ];
        show_hidden = true;
      };
      plugin.prepend_fetchers = [
        { id = "git"; url = "*"; run = "git"; }
        { id = "git"; url = "*/"; run = "git"; }
      ];
    };

    # ----- Theme / UI (theme.toml)
    theme = {
      flavor.dark = "base16";
      flavor.light = "base16";
      indicator.preview = { hidden = true; };
    };

    # ----- Keybindings (keymap.toml)
    keymap.mgr.prepend_keymap = [
      {
        on = "!";
        run = "shell \"kitty\" --orphan --confirm";
        desc = "Open Terminal in CWD";
      }
      {
        on = "R";
        run = "plugin omni-trash";
        desc = "Open Omni Trash menu";
      }
      {
        on = "M";
        run = "plugin mount";
        desc = "Open Mount menu";
      }
    ];

    # ----- Initialization (init.lua)
    initLua = ''
      require ("git"):setup {
        order = 1500,
      }
      -- Remove permissions from status bar
      Status:children_remove(4, Status.RIGHT)
    '';

    # ----- Plugins
    plugins = {
      git = pkgs.yaziPlugins.git;
      mount = pkgs.yaziPlugins.mount;
      omni-trash = pkgs.fetchFromGitHub {
        owner = "goon";
        repo = "omni-trash.yazi";
        rev = "main";
        hash = "sha256-18oUV39zqbZUdXuyWIUYpiCc84T4KFnelQcGwOXItf8=";
      };
    };

    # ----- Flavors
    flavors = {
      base16 = pkgs.fetchFromGitHub {
        owner = "matt-dong-123";
        repo = "base16.yazi";
        rev = "b02b7a8";
        hash = "sha256-qfo2/GLS6+KaUI5r6qMt6rHLkBifi2WW3lqLtwkkK/c=";
      };
    };
  };
}
