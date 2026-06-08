{ config, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    google-fonts
    corefonts
    material-symbols
    nerd-fonts.symbols-only
  ];

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
}
