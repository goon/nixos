{ pkgs, ... }:

{
  # Logitech Wireless Devices
  hardware.logitech.wireless.enable = true;
  boot.kernelModules = [ "hid-logitech-hidpp" ];

  # Wooting
  services.udev.packages = [ pkgs.wooting-udev-rules ];

  environment.systemPackages = with pkgs; [
    wootility
    brightnessctl
    ddcutil
  ];
}
