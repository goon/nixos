{ pkgs, ... }:

{
  # Logitech wireless devices
  hardware.logitech.wireless.enable = true;
  boot.kernelModules = [ "hid-logitech-hidpp" ];

  # Wooting keyboard support
  services.udev.packages = [ pkgs.wooting-udev-rules ];
  environment.systemPackages = with pkgs; [
    wootility
    brightnessctl
    ddcutil
  ];
}
