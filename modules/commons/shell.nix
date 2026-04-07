{
  config,
  lib,
  pkgs,
  username,
  repoName,
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
  options.module.shell.enable =
    lib.mkEnableOption "Unified Shell Environment (Zsh/Bash/Starship)"
    // {
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
      # CLI tools integration
      programs.eza.enable = true;
      programs.bat.enable = true;
      programs.fzf.enable = true;

      # Universal shell aliases
      home.shellAliases = {
        grep = "grep --color=auto";
        f = "fzf";
        partitions = "lsblk -f";
        v = "nvim";
        nv = "nvim";
        vim = "nvim";
        ls = "eza --icons --git";
        cat = "bat";
        cd = "z";
        rm = "rm -i";
        rqs = "pkill quickshell; quickshell & disown";
      };

      # zoxide (Smart cd)
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
      };

      # Session variables
      home.sessionVariables = {
        NH_FLAKE = "/home/${username}/${repoName}";
        EDITOR = "nvim";
        VISUAL = "nvim";
        BROWSER = "firefox";
      };

      home.sessionPath = [
        "$HOME/.local/bin"
      ];

      # Packages
      home.packages = [
        cheat-cmd
      ];

      # ----- Starship
      programs.starship = {
        enable = true;
        settings = {
          "$schema" = "https://starship.rs/config-schema.json";
          format = "$username$hostname$directory$git_branch$git_state$git_status$cmd_duration$line_break$python$character";
          directory.style = "blue";
          character = {
            success_symbol = "[❯](purple)";
            error_symbol = "[❯](red)";
            vimcmd_symbol = "[❮](green)";
          };
          git_branch = {
            format = "[$branch]($style)";
            style = "bright-black";
          };
          git_status = {
            format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
            style = "cyan";
            conflicted = "​";
            untracked = "​";
            modified = "​";
            staged = "​";
            renamed = "​";
            deleted = "​";
            stashed = "≡";
          };
          git_state = {
            format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
            style = "bright-black";
          };
          cmd_duration = {
            format = "[$duration]($style) ";
            style = "yellow";
          };
          python = {
            format = "[$virtualenv]($style) ";
            style = "bright-black";
            detect_extensions = [ ];
            detect_files = [ ];
          };
        };
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
          export NH_FLAKE="${config.home-manager.users.${username}.home.homeDirectory}/${repoName}"

        '';
      };

      # ----- Zsh
      programs.zsh = {
        enable = true;
        dotDir = "/home/${username}/.config/zsh";
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        oh-my-zsh = {
          enable = true;
          plugins = [
            "git"
            "sudo"
          ];
        };
        initContent = ''
          # ----- Exports
          export NH_FLAKE="/home/${username}/${repoName}"

        '';
      };
    };
  };
}
