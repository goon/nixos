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
{
  options.module.shell.enable = lib.mkEnableOption "Unified Shell Environment (Zsh/Bash)" // {
    default = true;
  };

  config = lib.mkIf config.module.shell.enable {
    programs.zsh.enable = true;

    users.users.${username}.shell = pkgs.zsh;

    environment.sessionVariables = {
      TERMINAL = config.globals.userTerminal;
    };

    home-manager.sharedModules = [
      {
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
            grep = "grep --color=auto";
            partitions = "lsblk -f";
            rm = "rm -i";

            f = "fzf";
          };

          sessionVariables = {
            BROWSER = "brave";
          };

          sessionPath = [
            "$HOME/.local/bin"
          ];

          packages = with pkgs; [
            cheat-cmd
            duf
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
          dotDir = "${config.globals.paths.config}/zsh";
          enableCompletion = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
        };
      }
    ];
  };
}
