{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.xdg.enable = lib.mkEnableOption "XDG MimeApps and Desktop Entries" // {
    default = true;
  };

  config = lib.mkIf config.module.xdg.enable {
    # System Layer
    environment.systemPackages = [ pkgs.xdg-user-dirs ];
    xdg.portal.enable = true;

    # User Layer (Home Manager)
    home-manager.users.${config._module.args.username} = {
      xdg.mimeApps = {
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
  };
}
