{
  config,
  lib,
  pkgs,
  ...
}:
lib.module config "fonts" false {
  config = {
    fonts.packages = with pkgs; [
      google-fonts
      corefonts
      noto-fonts
      libertine
      open-fonts
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
  };
}
