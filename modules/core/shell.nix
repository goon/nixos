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
        initExtra = ''
          _starship_first_prompt=1
          _starship_prompt_command() {
            if [[ -n "$_starship_first_prompt" ]]; then
              unset _starship_first_prompt
            else
              echo ""
            fi
          }
          if [ -n "$PROMPT_COMMAND" ]; then
            PROMPT_COMMAND="_starship_prompt_command; $PROMPT_COMMAND"
          else
            PROMPT_COMMAND="_starship_prompt_command"
          fi
        '';
      };

      zsh = {
        enable = true;
        dotDir = "${config.xdg.configHome}/zsh";
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        initContent = ''
          _starship_first_prompt=1
          precmd() {
            if [[ -n "$_starship_first_prompt" ]]; then
              unset _starship_first_prompt
            else
              print ""
            fi
          }
        '';
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
