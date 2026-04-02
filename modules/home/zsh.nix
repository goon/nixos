{ pkgs, repoName, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # ----- Oh My Zsh
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
      ];
    };

    # ----- Aliases (Duplicated from bash.nix for seamless transition)
    shellAliases = {
      # ----- Standard
      grep = "grep --color=auto";

      # ----- Nix
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

      # ----- Modern CLI
      ls = "eza --icons --git";
      cat = "bat";
      cd = "z";

      # ----- Utilities
      rm = "rm -i";
      rqs = "pkill quickshell; quickshell & disown";
    };

    # ----- Custom Initialisation
    initExtra = ''
      # ----- Exports
      export NH_FLAKE="$HOME/${repoName}"

      # ----- Auto Run
      ${pkgs.krabby}/bin/krabby random 1-3 --no-title
    '';
  };
}
