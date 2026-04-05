{ config, lib, ... }:

{
  options.module.git.enable = lib.mkEnableOption "Git" // {
    default = true;
  };

  config = lib.mkIf config.module.git.enable {
    home-manager.users.${config._module.args.username} = {
      programs.git = {
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
      programs.delta.enable = true;
      programs.lazygit.enable = true;

      home.shellAliases = {
        gs = "git status";
        ga = "git add";
        gc = "git commit -m";
        gp = "git push";
        lg = "lazygit";
      };
    };
  };
}
