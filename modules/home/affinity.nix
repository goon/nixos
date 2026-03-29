{ pkgs, inputs, user, ... }:

{
  # Garnix binary cache for affinity-nix
  nix.settings = {
    substituters = [ "https://cache.garnix.io" ];
    trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJPXNJQ=" ];
  };

  home-manager.users.${user} = {
    home.packages = [
      inputs.affinity-nix.packages.${pkgs.stdenv.system}.v3
    ];
  };
}
