{
  # Automatic USB Mounting
  services.udisks2.enable = true;

  # File Manager Services
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.gnome.localsearch.enable = true;

  # SSD Trim
  services.fstrim.enable = true;
}
