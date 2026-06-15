{ config, lib, ... }:

lib.module config "flatpak" true {
    services.flatpak = {
      enable = true;
      uninstallUnmanaged = true;
      update.onActivation = true;

      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];

      packages = [
        "com.usebottles.bottles"
        "com.parsecgaming.parsec"
      ];

      overrides = {
        "com.usebottles.bottles" = {
          Context.filesystems = [
            "/mnt/rocket"
            "xdg-data/Steam:ro"
          ];
          Environment = {
            WINE_SIMULATE_WRITECOPY = "1";
            WINE_DISABLE_GPU_SANDBOX = "1";
          };
        };
      };
    };}