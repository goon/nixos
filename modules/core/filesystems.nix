{
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/c6a3965a-5bf3-451c-934e-b391969c180a";
    fsType = "ext4";
  };

  # Automatic USB Mounting
  services.udisks2.enable = true;

  # File Manager Services
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.gnome.localsearch.enable = true;
}
