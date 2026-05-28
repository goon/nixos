{
  config,
  lib,
  username,
  repoPath,
  ...
}:

{
  # ========== Structural Essentials ==========
  # We use _module.args for these to avoid infinite recursion
  # when they are used in attribute names (like users.users.${username})

  config = {
    _module.args = {
      username = "michael";
      repoPath = "/home/${username}/.nixos";
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";

      users.${username} = {
        home = {
          inherit username;
          homeDirectory = config.globals.paths.home;
          stateVersion = "25.11";
        };
      };
    };
  };

  # ========== System Settings ==========

  options.globals = {
    userTerminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
      description = "default terminal emulator";
    };

    paths = {
      home = lib.mkOption {
        type = lib.types.str;
        default = "/home/${username}";
        description = "Absolute path to the user's home directory";
      };
    };

    repoPath = lib.mkOption {
      type = lib.types.str;
      default = repoPath;
      description = "Absolute path to the flake repository root";
    };

    userFonts = {
      sansSerif = lib.mkOption {
        type = lib.types.str;
        default = "Outfit";
        description = "global sans-serif font";
      };
      monospace = lib.mkOption {
        type = lib.types.str;
        default = "Kode Mono";
        description = "global monospace font";
      };
    };

    # ========== Default Applications ==========

    apps = {
      browser = lib.mkOption {
        type = lib.types.str;
        default = "brave-browser.desktop";
        description = "default web browser";
      };
      editor = lib.mkOption {
        type = lib.types.str;
        default = "nvim.desktop";
        description = "default text editor";
      };
      imageViewer = lib.mkOption {
        type = lib.types.str;
        default = "org.gnome.Loupe.desktop";
        description = "default image viewer";
      };
      videoPlayer = lib.mkOption {
        type = lib.types.str;
        default = "org.gnome.Totem.desktop";
        description = "default video player";
      };
      musicPlayer = lib.mkOption {
        type = lib.types.str;
        default = "org.gnome.Totem.desktop";
        description = "default music player";
      };
      fileManager = lib.mkOption {
        type = lib.types.str;
        default = "org.gnome.Nautilus.desktop";
        description = "default file manager";
      };
      pdfViewer = lib.mkOption {
        type = lib.types.str;
        default = "org.gnome.Evince.desktop";
        description = "default document viewer";
      };
    };
  };
}
