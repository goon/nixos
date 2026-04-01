{ pkgs, ... }:

{
  xdgDefaults.mediaPlayerPackage = null;

  programs.mpv = {
    enable = true;
    
    # [[ Main Config (mpv.conf) ]]
    config = {
      osc = "no";
      osd-font = "Outfit";
    };

    # [[ Managed Scripts (Official pkgs) ]]
    scripts = [
      pkgs.mpvScripts.thumbfast
      pkgs.mpvScripts.modernz
    ];

    # [[ Script Options (script-opts/*.conf) ]]
    scriptOpts = {
      modernz = {
        icon_theme = "material";
        font = "Outfit";
      };
    };
  };
}
