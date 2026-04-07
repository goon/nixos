{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
in
{
  options.module.hardware.radeon.enable = mkEnableOption "AMD Radeon GPU Support" // {
    default = false;
  };

  config = mkIf config.module.hardware.radeon.enable {
    # AMD GPUs
    boot.initrd.kernelModules = [ "amdgpu" ];
    boot.kernelModules = [ "i2c_dev" ];

    # Enable i2c support for things like ddcutil
    hardware.i2c.enable = true;

    services.xserver.videoDrivers = [ "amdgpu" ];
    environment.sessionVariables.LIBVA_DRIVER_NAME = "radeonsi";

    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      # Vulkan and OpenGL
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-headers
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        vulkan-loader
      ];
    };

    environment.systemPackages = with pkgs; [
      vulkan-tools
      mesa-demos
    ];
  };
}
