{
  config,
  lib,
  ...
}:

{
  options.module.xdg.enable = lib.mkEnableOption "XDG MimeApps and Desktop Entries" // {
    default = true;
  };

  options.globals.paths = {
    config = lib.mkOption {
      type = lib.types.str;
      default = "${config.globals.paths.home}/.config";
      description = "Absolute path to the XDG config home";
    };
    data = lib.mkOption {
      type = lib.types.str;
      default = "${config.globals.paths.home}/.local/share";
      description = "Absolute path to the XDG data home";
    };
    cache = lib.mkOption {
      type = lib.types.str;
      default = "${config.globals.paths.home}/.cache";
      description = "Absolute path to the XDG cache home";
    };
    state = lib.mkOption {
      type = lib.types.str;
      default = "${config.globals.paths.home}/.local/state";
      description = "Absolute path to the XDG state home";
    };
  };

  config = lib.mkIf config.module.xdg.enable {
    # System Layer
    environment.pathsToLink = [ "/share/applications" ];
    xdg.portal.enable = true;

    # User Layer (Home Manager)
    home-manager.sharedModules = [
      {
        xdg = {
          enable = true;
          userDirs = {
            enable = true;
            createDirectories = true;
            setSessionVariables = true;
          };
          mimeApps = {
            enable = true;
            defaultApplications =
              let
                inherit (config.globals) apps;
              in
              {
                "x-scheme-handler/http" = apps.browser;
                "x-scheme-handler/https" = apps.browser;
                "text/html" = apps.browser;
                "image/jpeg" = apps.imageViewer;
                "image/png" = apps.imageViewer;
                "video/mp4" = apps.videoPlayer;
                "inode/directory" = apps.fileManager;
                "application/pdf" = apps.pdfViewer;
                "text/plain" = apps.editor;
              };
          };
        };
      }
    ];
  };
}
