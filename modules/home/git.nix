_:

{
  programs.git = {
    enable = true;

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

  programs.delta.enable = true;
  programs.lazygit.enable = true;
}
