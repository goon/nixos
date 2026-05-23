{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.module.creative.enable = lib.mkEnableOption "Creative Suite (Affinity & DaVinci)" // {
    default = true;
  };

  config = lib.mkIf config.module.creative.enable {
    home-manager.users.${config._module.args.username} = {
      home.packages = [
        pkgs.affinity-v3
        pkgs.davinci-resolve
      ];
    };

    # Hardware tweaks for DaVinci Resolve on Radeon
    hardware.amdgpu.opencl.enable = lib.mkIf config.module.hardware.radeon.enable true;
  };
}
