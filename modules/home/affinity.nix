{
  pkgs,
  inputs,
  ...
}:

{
  home.packages = [
    inputs.affinity-nix.packages.${pkgs.stdenv.system}.v3
  ];
}
