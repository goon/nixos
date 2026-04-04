{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  options.module.affinity.enable = lib.mkEnableOption "Affinity Suite" // {
    default = true;
  };

  config = lib.mkIf config.module.affinity.enable {
    home-manager.users.${config._module.args.username} = {
      home.packages = [
        inputs.affinity-nix.packages.${pkgs.stdenv.system}.v3
      ];
    };
  };
}
