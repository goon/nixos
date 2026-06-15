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
      description = "The state version for both NixOS and Home Manager";
    };

    userTerminal = lib.opt lib.types.str "kitty" "default terminal emulator";

    paths = {
      home = lib.opt lib.types.str "/home/${username}" "Absolute path to the user's home directory";
    };

    repoPath = lib.opt lib.types.str repoPath "Absolute path to the flake repository root";

    userFonts = {
      sansSerif = lib.opt lib.types.str "Outfit" "global sans-serif font";
      monospace = lib.opt lib.types.str "Kode Mono" "global monospace font";
    };

    # ========== Default Applications ==========

    apps = {
      browser = lib.opt lib.types.str "firefox.desktop" "default web browser";
      editor = lib.opt lib.types.str "nvim.desktop" "default text editor";
      imageViewer = lib.opt lib.types.str "org.gnome.Loupe.desktop" "default image viewer";
      videoPlayer = lib.opt lib.types.str "org.gnome.Totem.desktop" "default video player";
      musicPlayer = lib.opt lib.types.str "org.gnome.Totem.desktop" "default music player";
      fileManager = lib.opt lib.types.str "org.gnome.Nautilus.desktop" "default file manager";
      pdfViewer = lib.opt lib.types.str "org.gnome.Evince.desktop" "default document viewer";
    };
  };
}
