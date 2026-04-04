{ config, pkgs, ... }:

{
  # System-wide Fonts
  fonts.packages = with pkgs; [
    google-fonts
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
