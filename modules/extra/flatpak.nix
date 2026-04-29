{ config, lib, ... }:

{
  options.module.flatpak.enable = lib.mkEnableOption "Flatpak" // {
    default = true;
  };

  config = lib.mkIf config.module.flatpak.enable {
    services.flatpak = {
      enable = true;
      uninstallUnmanaged = true;
      update.onActivation = true;

      remotes = [{
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }];

      packages = [
        "com.usebottles.bottles"
        "com.parsecgaming.parsec"
      ];

      overrides = {
        "com.usebottles.bottles" = {
          Context.filesystems = [ "/mnt/games" ];
        };
      };
    };
  };
}
