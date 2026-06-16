{
  config,
  lib,
  ...
}:

lib.module config "logitech" false {
  hardware.logitech.wireless.enable = true;
  boot.kernelModules = [ "hid-logitech-hidpp" ];
}
