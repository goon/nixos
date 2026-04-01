{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.xdgDefaults = with lib; {
    browser = mkOption {
      type = types.str;
      default = "firefox.desktop";
      description = "Default browser desktop entry";
    };

    imageViewerPackage = mkOption {
      type = types.nullOr types.package;
      default = pkgs.imv;
    };
    imageViewer = mkOption {
      type = types.str;
      default = "imv.desktop";
    };

    mediaPlayerPackage = mkOption {
      type = types.nullOr types.package;
      default = pkgs.mpv;
    };
    mediaPlayer = mkOption {
      type = types.str;
      default = "mpv.desktop";
    };
  };

  config =
    let
      cfg = config.xdgDefaults;
    in
    {
      home.packages =
        (lib.optional (cfg.imageViewerPackage != null) cfg.imageViewerPackage)
        ++ (lib.optional (cfg.mediaPlayerPackage != null) cfg.mediaPlayerPackage);

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          # ----- Browser
          "x-scheme-handler/http" = cfg.browser;
          "x-scheme-handler/https" = cfg.browser;
          "text/html" = cfg.browser;
          "image/svg+xml" = cfg.browser;

          # ----- Images
          "image/jpeg" = cfg.imageViewer;
          "image/png" = cfg.imageViewer;
          "image/gif" = cfg.imageViewer;
          "image/webp" = cfg.imageViewer;
          "image/bmp" = cfg.imageViewer;
          "image/tiff" = cfg.imageViewer;

          # ----- Video
          "video/mp4" = cfg.mediaPlayer;
          "video/webm" = cfg.mediaPlayer;
          "video/x-matroska" = cfg.mediaPlayer;
          "video/x-msvideo" = cfg.mediaPlayer;
          "video/quicktime" = cfg.mediaPlayer;
          "video/x-mpeg" = cfg.mediaPlayer;

          # ----- Audio
          "audio/mpeg" = cfg.mediaPlayer;
          "audio/flac" = cfg.mediaPlayer;
          "audio/ogg" = cfg.mediaPlayer;
          "audio/wav" = cfg.mediaPlayer;
          "audio/aac" = cfg.mediaPlayer;
        };
      };

      # ----- Override → Neovim Wrapper 
      xdg.desktopEntries.nvim = {
        name = "Neovim";
        genericName = "Text Editor";
        exec = "nvim %F";
        terminal = true;
        type = "Application";
        categories = [
          "Utility"
          "TextEditor"
        ];
        icon = "nvim";
        startupNotify = false;
        mimeType = [
          "text/english"
          "text/plain"
          "text/x-makefile"
          "text/x-c++hdr"
          "text/x-c++src"
          "text/x-chdr"
          "text/x-csrc"
          "text/x-java"
          "text/x-moc"
          "text/x-pascal"
          "text/x-tcl"
          "text/x-tex"
          "application/x-shellscript"
          "text/x-c"
          "text/x-c++"
        ];
      };
    };
}
