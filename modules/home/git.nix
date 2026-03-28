{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    
    # Global ignore patterns
    ignores = [ 
      "AGENTS.md"
    ];

    settings = {
      user = {
        name = "goon";
        email = "hayhurst@protonmail.com";
      };
      
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      fetch.prune = true;
    };
  };

  programs.delta.enable = true; # advanced 'diff' tool and syntax highlighting 
  programs.lazygit.enable = true; # lazy git tui 
}
