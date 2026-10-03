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
              "image/svg"
              "image/jpeg"
              "image/jpg"
              "image/gif"
              "image/webp"
            ])
            ++ (assoc apps.mediaPlayer [
              "video/mp4"
              "video/avi"
              "video/mkv"
              "video/webm"
              "audio/mp3"
              "audio/flac"
              "audio/wav"
              "audio/aac"
              "audio/ogg"
            ])
            ++ (assoc apps.browser [
              "application/pdf"
              "application/json"
              "application/xhtml+xml"
              "application/x-extension-htm"
              "application/x-extension-html"
              "application/x-extension-shtml"
              "application/x-extension-xht"
              "application/x-extension-xhtml"
              "x-scheme-handler/about"
              "x-scheme-handler/chrome"
              "x-scheme-handler/ftp"
              "x-scheme-handler/http"
              "x-scheme-handler/https"
              "x-scheme-handler/unknown"
            ])
          );
      };
    };
  };
}
