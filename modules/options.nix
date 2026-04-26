{ config, lib, ... }:

let
  inherit (lib) mkOption types;
in
{
  # ========== Structural Essentials ==========
  # We use _module.args for these to avoid infinite recursion
  # when they are used in attribute names (like users.users.${username})

  config = {
    _module.args = {
      username = "michael";
      repoName = ".nixos";
    };
  };

  # ========== System Settings ==========

  options.globals = {
    userTerminal = mkOption {
      type = types.str;
      default = "kitty";
      description = "default terminal emulator";
    };

    paths = {
      home = mkOption {
        type = types.str;
        default = "/home/${config._module.args.username}";
        description = "Absolute path to the user's home directory";
      };
    };

    repoPath = mkOption {
      type = types.str;
      default = "${config.globals.paths.home}/${config._module.args.repoName}";
      description = "Absolute path to the flake repository root";
    };

    userFonts = {
      sansSerif = mkOption {
        type = types.str;
        default = "Parkinsans";
        description = "global sans-serif font";
      };
      monospace = mkOption {
        type = types.str;
        default = "Kode Mono";
        description = "global monospace font";
      };
    };

    # ========== Default Applications ==========

    apps = {
      browser = mkOption {
        type = types.str;
        default = "brave-browser.desktop";
        description = "default web browser";
      };
      editor = mkOption {
        type = types.str;
        default = "nvim.desktop";
        description = "default text editor";
      };
      imageViewer = mkOption {
        type = types.str;
        default = "org.gnome.Loupe.desktop";
        description = "default image viewer";
      };
      videoPlayer = mkOption {
        type = types.str;
        default = "org.gnome.Totem.desktop";
        description = "default video player";
      };
      musicPlayer = mkOption {
        type = types.str;
        default = "org.gnome.Totem.desktop";
        description = "default music player";
      };
      fileManager = mkOption {
        type = types.str;
        default = "org.gnome.Nautilus.desktop";
        description = "default file manager";
      };
      pdfViewer = mkOption {
        type = types.str;
        default = "org.gnome.Evince.desktop";
        description = "default document viewer";
      };
    };
  };
}
