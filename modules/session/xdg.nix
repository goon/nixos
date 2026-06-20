{
  config,
  lib,
  pkgs,
  ...
}:

lib.module config "xdg" false {
  config = {
    environment.systemPackages = [ pkgs.xdg-user-dirs ];
    environment.pathsToLink = [ "/share/applications" ];
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
    };
  };

  home = {
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
            xdgAssociations =
              type: program: list:
              builtins.listToAttrs (
                map (e: {
                  name = "${type}/${e}";
                  value = program;
                }) list
              );

            image = xdgAssociations "image" apps.imageViewer [
              "png"
              "svg"
              "jpeg"
              "jpg"
              "gif"
              "webp"
            ];
            video = xdgAssociations "video" apps.videoPlayer [
              "mp4"
              "avi"
              "mkv"
              "webm"
            ];
            audio = xdgAssociations "audio" apps.musicPlayer [
              "mp3"
              "flac"
              "wav"
              "aac"
              "ogg"
            ];
            browserTypes =
              (xdgAssociations "application" apps.browser [
                "json"
                "x-extension-htm"
                "x-extension-html"
                "x-extension-shtml"
                "x-extension-xht"
                "x-extension-xhtml"
                "xhtml+xml"
              ])
              // (xdgAssociations "x-scheme-handler" apps.browser [
                "about"
                "chrome"
                "ftp"
                "http"
                "https"
                "unknown"
              ]);
          in
          {
            "application/pdf" = apps.pdfViewer;
            "text/plain" = apps.editor;
            "inode/directory" = apps.fileManager;
          }
          // image
          // video
          // audio
          // browserTypes;
      };
    };

    home.packages = [
      (pkgs.writeShellScriptBin "xdg-terminal-exec" ''
        ${config.globals.userTerminal} "$@"
      '')
      pkgs.xdg-utils
    ];
  };
}
