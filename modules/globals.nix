{
  config,
  lib,
  username,
  repo,
  ...
}:

{
  # ========== Structural Essentials ==========

  config = {

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";

      users.${username} = {
        home = {
          inherit username;
          homeDirectory = config.globals.paths.home;
          stateVersion = config.globals.stateVersion;
        };
      };
    };

    system.stateVersion = config.globals.stateVersion;
  };

  # ========== System Settings ==========

  options.globals = {
    stateVersion = lib.mkOption {
      type = lib.types.str;
    };

    userTerminal = lib.opt lib.types.str "kitty";

    paths = {
      home = lib.opt lib.types.str "/home/${username}";
    };

    repo = lib.opt lib.types.str repo;

    userFonts = {
      sansSerif = lib.opt lib.types.str "Outfit";
      monospace = lib.opt lib.types.str "Kode Mono";
    };

    # ========== Default Applications ==========

    apps = {
      browser = lib.opt lib.types.str "firefox.desktop";
      editor = lib.opt lib.types.str "nvim.desktop";
      imageViewer = lib.opt lib.types.str "org.gnome.Loupe.desktop";
      videoPlayer = lib.opt lib.types.str "org.gnome.Totem.desktop";
      musicPlayer = lib.opt lib.types.str "com.vixalien.decibels.desktop";
      fileManager = lib.opt lib.types.str "org.gnome.Nautilus.desktop";
      pdfViewer = lib.opt lib.types.str "org.gnome.Evince.desktop";
    };
  };
}
