{ pkgs, fonts, ... }:

{
  _module.args.fonts = {
    sansSerif = "Outfit";
    monospace = "Kode Mono";
  };

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
      monospace = [ fonts.monospace ];
      sansSerif = [ fonts.sansSerif ];
    };
  };
}
