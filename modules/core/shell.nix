{
  config,
  lib,
  pkgs,
  username,
  ...
}:
lib.module config "shell" true {
  config = {
    programs.zsh.enable = true;

    users.users.${username}.shell = pkgs.zsh;

    environment.sessionVariables = {
      TERMINAL = config.globals.userTerminal;
    };
  };

  homeManager =
    {
      config,
      globals,
      ...
    }:
    {
      home.packages = with pkgs; [
        bat
        btop
        curl
        duf
        eza
        fd
        jq
        ripgrep
        unzip
      ];
      programs = {
        fzf.enable = true;
        zoxide.enable = true;

        zsh = {
          enable = true;
          dotDir = "${config.xdg.configHome}/zsh";
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
        };
      };

      home = {
        shellAliases = {
          ".." = "cd ..";
          "..." = "cd ../..";
          cd = "z";
          cdi = "zi";
          cat = "bat";
          df = "duf";
          find = "fd";
          grep = "rg";
          ls = "eza --git";
          tree = "eza --tree";
          rm = "rm -i";
        };

        sessionVariables = {
          BROWSER = lib.removeSuffix ".desktop" globals.apps.browser;
        };

        sessionPath = [
          "$HOME/.local/bin"
        ];
      };
    };
}
