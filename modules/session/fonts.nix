{
  config,
  lib,
  pkgs,
  ...
}:
let
  supplied = builtins.filter lib.isDerivation (
    builtins.attrValues (pkgs.callPackage ../../pkgs/ag.nix { })
  );
in
lib.module config "fonts" false {
  config = {
    fonts.packages =
      with pkgs;
      [
        google-fonts
        corefonts
        noto-fonts
        libertine
        open-fonts
        material-symbols
        nerd-fonts.symbols-only
        source-sans
        source-serif
        source-code-pro
        league-of-moveable-type
      ]
      ++ supplied;

    fonts.fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        lcdfilter = "default";
        rgba = "rgb";
      };
      defaultFonts = {
        monospace = [ config.globals.userFonts.monospace ];
        sansSerif = [ config.globals.userFonts.sansSerif ];
      };
    };
  };
}
