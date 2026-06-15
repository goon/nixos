{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "yazi" true {
  userPkgs = [ pkgs.trash-cli ];

  home = {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      settings = {
        mgr = {
          ratio = [
            2
            4
            3
          ];
          show_hidden = true;
        };
        plugin.prepend_fetchers = [
          {
            id = "git";
            url = "*";
            run = "git";
            group = "git";
          }
          {
            id = "git";
            url = "*/";
            run = "git";
            group = "git";
          }
        ];
      };
      theme = {
        flavor.dark = "base16";
        flavor.light = "base16";
        indicator.preview = {
          hidden = true;
        };
      };
      keymap.mgr.prepend_keymap = [
        {
          on = "!";
          run = "shell \"${config.globals.userTerminal}\" --orphan --confirm";
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
      initLua = ''
        require ("git"):setup { order = 1500 }
        Status:children_remove(4, Status.RIGHT)
      '';
      plugins = {
        inherit (pkgs.yaziPlugins) git mount;
        omni-trash = pkgs.fetchFromGitHub {
          owner = "goon";
          repo = "omni-trash.yazi";
          rev = "06d7584d1a2d8f1174758db370cc16897ff39696";
          hash = "sha256-jdSi8uNFKQS2Skn2OJNDPKYw9VmAd2V+Cor60MDLNt4=";
        };
      };
      flavors = {
        base16 = pkgs.fetchFromGitHub {
          owner = "matt-dong-123";
          repo = "base16.yazi";
          rev = "b02b7a8";
          hash = "sha256-qfo2/GLS6+KaUI5r6qMt6rHLkBifi2WW3lqLtwkkK/c=";
        };
      };
    };
  };
}
