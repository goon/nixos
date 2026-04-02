{ pkgs, ... }:

{
  # AMD GPUs
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "i2c_dev" ];
  hardware.i2c.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

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

  # SSD Trim
  services.fstrim.enable = true;
}
