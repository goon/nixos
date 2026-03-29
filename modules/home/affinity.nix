{ pkgs, inputs, user, ... }:

{
  home-manager.users.${user} = {
    home.packages = [
      inputs.affinity-nix.packages.${pkgs.stdenv.system}.v3
    ];
  };
}
