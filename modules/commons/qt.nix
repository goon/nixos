{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
in
{
  options.module.qt.enable = mkEnableOption "Qt Environment" // {
    default = true;
  };

  config = mkIf config.module.qt.enable {
    # ========== System Layer (NixOS) ==========
    environment.sessionVariables = {
      QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";

      # General Qt Scaling settings
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_SCALE_FACTOR = "1";
      QT_FONT_DPI = "96";
    }
    // (lib.optionalAttrs config.module.wayland.enable {
      # Wayland-specific Qt settings
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    });

    # ========== User Layer (Home Manager) ==========
    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          qt6Packages.qt6ct
        ];
      }
    ];
  };
}
