{
  config,
  lib,
  pkgs,
  ...
}:
lib.module config "xdg" false {
  config = {
    environment.systemPackages = [
      pkgs.xdg-user-dirs
      pkgs.xdg-terminal-exec
    ];
    environment.pathsToLink = [ "/share/applications" ];
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
    };
  };

  homeManager = {
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
            assoc = app: map (m: lib.nameValuePair m app);
          in
          {
            "text/plain" = apps.editor;
            "inode/directory" = apps.fileManager;
          }
          // lib.listToAttrs (
            (assoc apps.imageViewer [
              "image/png"
              "image/svg+xml"
              "image/jpeg"
              "image/gif"
              "image/webp"
            ])
            ++ (assoc apps.mediaPlayer [
              "audio/mpeg"
              "audio/flac"
              "audio/vnd.wave"
              "audio/aac"
              "audio/ogg"
              "video/mp4"
              "video/vnd.avi"
              "video/matroska"
              "video/webm"
            ])
            ++ (assoc apps.browser [
              "text/html"
              "application/pdf"
              "application/json"
              "application/xhtml+xml"
              "x-scheme-handler/about"
              "x-scheme-handler/chrome"
              "x-scheme-handler/ftp"
              "x-scheme-handler/http"
              "x-scheme-handler/https"
            ])
          );
      };
    };
  };
}
