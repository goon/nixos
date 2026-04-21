{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
  options.module.spicetify.enable = lib.mkEnableOption "Spicetify" // {
    default = true;
  };

  config = lib.mkIf config.module.spicetify.enable {
    home-manager.users.${config._module.args.username} = {
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
  };
}
