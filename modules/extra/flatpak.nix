{ config, lib, ... }:

{
  options.module.flatpak.enable = lib.mkEnableOption "Flatpak" // {
    default = true;
  };

  config = lib.mkIf config.module.flatpak.enable {
    services.flatpak = {
      enable = true;
      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      };
      packages = [
        "flathub:app/com.usebottles.bottles/x86_64/stable"
      ];
      overrides = {
        "com.usebottles.bottles" = {
          Context.filesystems = [ "/mnt/games" ];
        };
      };
    };
  };
}
