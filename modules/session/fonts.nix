{
  config,
  lib,
  pkgs,
  ...
}:
lib.module config "fonts" false {
  config = {
    fonts.packages = with pkgs; [
      corefonts
      google-fonts
      noto-fonts
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
