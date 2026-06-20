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

  userPkgs = with pkgs; [
    (writeShellScriptBin "cheat" ''curl "https://cheat.sh/$1"'')
    curl
    duf
    gum
    unzip
    wget
  ];

  home = { config, globals, ... }: {
    programs = {
      bat.enable = true;
      btop.enable = true;
      eza.enable = true;
      fd.enable = true;
      fzf.enable = true;
      jq.enable = true;
      ripgrep.enable = true;

      zoxide = {
        enable = true;
        options = [
          "--cmd cd"
        ];
      };

      bash = {
        enable = true;
        enableCompletion = true;
        historyControl = [
          "ignoreboth"
          "erasedups"
        ];
        historyFileSize = 20000;
        shellOptions = [
          "histappend"
          "checkwinsize"
        ];
      };

      zsh = {
        enable = true;
        dotDir = "${config.xdg.configHome}/zsh";
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
      };
    };

    home = {
      shellAliases = {
        c = "clear";
        h = "history";
        ".." = "cd ..";
        "..." = "cd ../..";
        cat = "bat";
        df = "duf";
        f = "fzf";
        find = "fd";
        grep = "rg";
        ls = "eza --icons --git";
        rm = "rm -i";
        tree = "eza --tree";
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
