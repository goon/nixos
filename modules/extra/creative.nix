{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  options.module.creative.enable = lib.mkEnableOption "Creative Suite (Affinity)" // {
    default = true;
  };

  config = lib.mkIf config.module.creative.enable {
    nixpkgs.overlays = [ inputs.affinity-nix.overlays.default ];

    home-manager.sharedModules = [
      {
        home.packages = [
          pkgs.affinity-v3
        ];
      }
    ];
  };
}
