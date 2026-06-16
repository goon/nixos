{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
lib.module config "spicetify" false {
  home = {
    imports = [
      inputs.spicetify-nix.homeManagerModules.default
    ];

    # Spicetify
    programs.spicetify = {
      enable = true;
      theme = spicePkgs.themes.comfy;
      colorScheme = "Mono";
      enabledExtensions = with spicePkgs.extensions; [
        hidePodcasts
        adblockify
      ];
    };
  };
}
