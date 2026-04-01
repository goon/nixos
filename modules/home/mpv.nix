{ pkgs, fonts, ... }:

{
  xdgDefaults.mediaPlayerPackage = null;

  programs.mpv = {
    enable = true;

    config = {
      osc = "no";
      osd-font = fonts.sansSerif;
    };

    # ----- Scripts
    scripts = [
      pkgs.mpvScripts.thumbfast
      pkgs.mpvScripts.modernz
    ];

    scriptOpts = {
      modernz = {
        icon_theme = "material";
        font = fonts.sansSerif;
      };
    };
  };
}
