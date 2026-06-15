{
  config,
  lib,
  ...
}:

lib.module config "git" true {
    home-manager.sharedModules = [
      {
        programs = {
          git = {
            enable = true;
            ignores = [ "AGENTS.md" ];
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
          delta.enable = true;
          lazygit.enable = true;
        };

        home.shellAliases = {
          gs = "git status";
          ga = "git add";
          gc = "git commit -m";
          gp = "git push";
          lg = "lazygit";
        };
      }
    ];}