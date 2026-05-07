{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  inherit (lib) mkIf;

  # ----- Cheat (from bash.nix)
  cheat-cmd = pkgs.writeShellScriptBin "cheat" ''
    curl "https://cheat.sh/$1"
  '';
in
{
  options.module.shell.enable = lib.mkEnableOption "Unified Shell Environment (Zsh/Bash)" // {
    default = true;
  };

  config = mkIf config.module.shell.enable {
    # ========== NixOS Layer ==========
    programs.zsh.enable = true;

    users.users.${username}.shell = pkgs.zsh;

    environment.sessionVariables = {
      TERM = config.globals.userTerminal;
      TERMINAL = config.globals.userTerminal;
    };

    # ========== Home Manager Layer ==========
    home-manager.users.${username} = {
      programs = {
        # CLI tools integration
        eza.enable = true;
        bat.enable = true;
        fzf.enable = true;
      };

      # Universal shell aliases
      home.shellAliases = {
        # --- Navigation
        ".." = "cd ..";
        "..." = "cd ../..";
        cd = "z";
        ls = "eza --icons --git";

        # --- System Utilities
        cat = "bat";
        df = "duf";
        grep = "grep --color=auto";
        partitions = "lsblk -f";
        rm = "rm -i";

        # --- Search & Filtering
        f = "fzf";
      };

      # Session variables
      home.sessionVariables = {
        BROWSER = "brave";
      };

      home.sessionPath = [
        "$HOME/.local/bin"
      ];

      # Packages
      home.packages = with pkgs; [
        cheat-cmd
        duf
      ];

      # zoxide (Smart cd)
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
      };

      # ----- Bash
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
        initExtra = ''
          # ----- Exports

        '';
      };

      # ----- Zsh
      programs.zsh = {
        enable = true;
        dotDir = "${config.globals.paths.config}/zsh";
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        initContent = ''
          # ----- Exports

        '';
      };
    };
  };
}
