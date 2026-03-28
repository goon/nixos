{ pkgs, fonts, ... }:

{
  fonts.packages = with pkgs; [
    google-fonts
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
      monospace = [ fonts.monospace ];
      sansSerif = [ fonts.sansSerif ];
    };
  };
}
