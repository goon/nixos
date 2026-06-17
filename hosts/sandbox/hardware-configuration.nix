{
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "mptspi"
    "uhci_hcd"
    "ehci_pci"
    "sd_mod"
    "sr_mod"
  ];

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
}
