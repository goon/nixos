{
  config,
  lib,
  pkgs,
  ...
}:
lib.module config "radeon" false {
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "i2c_dev" ];

  hardware.i2c.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" ];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "radeonsi";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
    ];
  };

  environment.systemPackages = with pkgs; [
    vulkan-tools
    mesa-demos
  ];
}
