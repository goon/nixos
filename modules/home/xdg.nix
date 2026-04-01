{
  config,
  ...
}:

{
  config =
    let
      inherit (config.globals) apps;
    in
    {
      home.packages = [ ]; # Packages are managed in gnome.nix or individual modules

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          # ----- Browser
          "x-scheme-handler/http" = apps.browser;
          "x-scheme-handler/https" = apps.browser;
          "text/html" = apps.browser;
          "image/svg+xml" = apps.browser;

          # ----- Images
          "image/jpeg" = apps.imageViewer;
          "image/png" = apps.imageViewer;
          "image/gif" = apps.imageViewer;
          "image/webp" = apps.imageViewer;
          "image/bmp" = apps.imageViewer;
          "image/tiff" = apps.imageViewer;

          # ----- Video
          "video/mp4" = apps.videoPlayer;
          "video/webm" = apps.videoPlayer;
          "video/x-matroska" = apps.videoPlayer;
          "video/x-msvideo" = apps.videoPlayer;
          "video/quicktime" = apps.videoPlayer;
          "video/x-mpeg" = apps.videoPlayer;

          # ----- Audio
          "audio/mpeg" = apps.musicPlayer;
          "audio/flac" = apps.musicPlayer;
          "audio/ogg" = apps.musicPlayer;
          "audio/wav" = apps.musicPlayer;
          "audio/aac" = apps.musicPlayer;
          "audio/x-vorbis+ogg" = apps.musicPlayer;
          "audio/x-flac" = apps.musicPlayer;
          "audio/x-wav" = apps.musicPlayer;

          # ----- File Manager
          "inode/directory" = apps.fileManager;

          # ----- Documents
          "application/pdf" = apps.pdfViewer;
          "application/epub+zip" = apps.pdfViewer;
          "application/x-mobipocket-ebook" = apps.pdfViewer;
          "application/vnd.comicbook-rar" = apps.pdfViewer;
          "application/vnd.comicbook+zip" = apps.pdfViewer;

          # ----- Text & Config
          "text/plain" = apps.editor;
          "text/markdown" = apps.editor;
          "application/toml" = apps.editor;
          "text/x-toml" = apps.editor;
          "text/x-config" = apps.editor;
          "text/x-yaml" = apps.editor;
          "application/yaml" = apps.editor;
          "application/x-yaml" = apps.editor;
          "text/x-python" = apps.editor;
          "text/x-shellscript" = apps.editor;
          "text/x-makefile" = apps.editor;
          "text/x-csrc" = apps.editor;
          "text/x-c++src" = apps.editor;
        };
      };

      # ----- Override → Neovim Wrapper
      xdg.desktopEntries.nvim = {
        name = "Neovim";
        genericName = "Text Editor";
        exec = "${config.globals.userTerminal} nvim %F";
        terminal = false;
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
          "application/toml"
          "text/x-toml"
          "text/x-config"
          "text/x-yaml"
          "application/yaml"
          "application/x-yaml"
          "text/markdown"
          "text/x-python"
        ];
      };
    };
}
