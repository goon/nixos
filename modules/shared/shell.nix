{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cheat-cmd = pkgs.writeShellScriptBin "cheat" ''
    curl "https://cheat.sh/$1"
  '';
in
lib.module config "shell" true {
  config = {
    programs.zsh.enable = true;

    users.users.${username}.shell = pkgs.zsh;

    environment.sessionVariables = {
      TERMINAL = config.globals.userTerminal;
    };
  };

  userPkgs = with pkgs; [
    cheat-cmd
    duf
    fd
    gum
    ripgrep
    wget
    curl
    unzip
    btop
    jq
  ];

  home = { config, ... }: {
    programs = {
      eza.enable = true;
      bat.enable = true;
      fzf.enable = true;
    };

    home = {
      shellAliases = {
        ".." = "cd ..";
        "..." = "cd ../..";
        ls = "eza --icons --git";

        cat = "bat";
        df = "duf";
        tree = "eza --tree";
        find = "fd";
        grep = "rg";
        rm = "rm -i";
        f = "fzf";
      };

      sessionVariables = {
        BROWSER = "firefox";
      };

      sessionPath = [
        "$HOME/.local/bin"
      ];
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      options = [
        "--cmd cd"
      ];
    };

    programs.bash = {
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

    programs.zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };
  };
}
