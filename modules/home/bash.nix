{ config, pkgs, lib, ... }:

let
  # ----- Standalone cheat command (shell-agnostic)
  cheat-cmd = pkgs.writeShellScriptBin "cheat" ''
    curl "https://cheat.sh/$1"
  '';
in
{
  # ----- CLI Tools enabled via Home Manager modules
  programs.zoxide.enable = true;
  programs.fzf.enable = true;
  programs.bat.enable = true;
  programs.eza.enable = true;

  # ----- Environment Variables
  home.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
  };

  # ----- Add to PATH
  home.sessionPath = [
    "$HOME/.local/bin"
  ];


  programs.bash = {
    enable = true;
    enableCompletion = true;

    # ----- History Settings
    historyControl = [ "ignoreboth" "erasedups" ];
    historySize = 10000;
    historyFileSize = 20000;
    
    shellOptions = [
      "histappend"
      "checkwinsize"
    ];

    # ----- Aliases
    shellAliases = {
      # ----- Standard
      grep = "grep --color=auto";
      
      # ----- Nix/NH
      nhs = "nh os switch";
      nht = "nh os test";
      nhc = "nh clean all --keep 8";
      nhu = "nh os switch -u";

      # ----- FZF
      f = "fzf";

      # ----- Disk
      partitions = "lsblk -f";

      # ----- Git
      gs = "git status";
      ga = "git add";
      gc = "git commit -m";
      gp = "git push";
      lg = "lazygit";

      # ----- Neovim
      v = "nvim";
      nv = "nvim";
      vim = "nvim";

      # ----- Modern CLI replacements
      ls = "eza --icons --git";
      cat = "bat";
      cd = "z"; # zoxide integration

      # ----- Utilities
      rm = "rm -i";
      rqs = "pkill quickshell; quickshell & disown";
    };

    # ----- Custom Initialisation
    initExtra = ''
      # ----- Exports
      export NH_FLAKE="$HOME/.nixos"

      # ----- Functions

      # ----- Auto Run
      ${pkgs.krabby}/bin/krabby random 1-3 --no-title
    '';
  };

  # ----- Custom Packages - Managed alongside their configurations
  home.packages = [
    cheat-cmd
    pkgs.krabby
  ];
}
