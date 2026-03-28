{ pkgs, ... }:

{
  # AMD GPU configuration
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "i2c_dev" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    # AMD Vulkan and OpenGL support
    # RADV (Mesa's Vulkan driver) is enabled by default for AMD GPUs
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-headers
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
    ];
  };

  # Graphics/GPU tools
  environment.systemPackages = with pkgs; [
    vulkan-tools
    mesa-demos
  ];

  # SSD TRIM for NVMe drives
  services.fstrim.enable = true;
}
