_:

{
  # Mount games drive
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/c6a3965a-5bf3-451c-934e-b391969c180a";
    fsType = "ext4";
  };

  # Auto-mount USB drives
  services.udisks2.enable = true;

  # File manager services
  services.gvfs.enable = true; # Required for Nautilus (mounts, trash, preferences)
  services.tumbler.enable = true; # Thumbnail generation for Nautilus
  services.gnome.localsearch.enable = true; # File indexing for Nautilus search
}
