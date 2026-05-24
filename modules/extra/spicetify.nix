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
{
  options.module.spicetify.enable = lib.mkEnableOption "Spicetify" // {
    default = true;
  };

  config = lib.mkIf config.module.spicetify.enable {
    home-manager.sharedModules = [
      {
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
      }
    ];
  };
}
