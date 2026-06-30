{
  config,
  lib,
  username,
  repo,
  ...
}:
{
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

  options.globals = {
    stateVersion = lib.mkOption {
      type = lib.types.str;
    };

    userTerminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
    };

    paths = {
      home = lib.mkOption {
        type = lib.types.str;
        default = "/home/${username}";
      };
    };

    repo = lib.mkOption {
      type = lib.types.str;
      default = repo;
    };

    userFonts = {
      sansSerif = lib.mkOption {
        type = lib.types.str;
        default = "Outfit";
      };
      monospace = lib.mkOption {
        type = lib.types.str;
        default = "Kode Mono";
      };
    };

    apps = {
      browser = lib.mkOption {
        type = lib.types.str;
        default = "firefox.desktop";
      };
      editor = lib.mkOption {
        type = lib.types.str;
        default = "nvim.desktop";
      };
      imageViewer = lib.mkOption {
        type = lib.types.str;
        default = "org.gnome.Loupe.desktop";
      };
      videoPlayer = lib.mkOption {
        type = lib.types.str;
        default = "org.gnome.Totem.desktop";
      };
      musicPlayer = lib.mkOption {
        type = lib.types.str;
        default = "com.vixalien.decibels.desktop";
      };
      fileManager = lib.mkOption {
        type = lib.types.str;
        default = "org.gnome.Nautilus.desktop";
      };
      pdfViewer = lib.mkOption {
        type = lib.types.str;
        default = "org.gnome.Evince.desktop";
      };
    };
  };
}
