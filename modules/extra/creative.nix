{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  options.module.creative.enable = lib.mkEnableOption "Creative Suite (Affinity & DaVinci)" // {
    default = true;
  };

  config = lib.mkIf config.module.creative.enable {
    nixpkgs.overlays = [ inputs.affinity-nix.overlays.default ];

    home-manager.users.${config._module.args.username} = {
      home.packages = [
        pkgs.affinity-v3
        pkgs.davinci-resolve
      ];

      home.file = {
        ".local/share/applications/blackmagicraw-player.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Blackmagic RAW Player
          NoDisplay=true
        '';
        ".local/share/applications/blackmagicraw-speedtest.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Blackmagic RAW Speed Test
          NoDisplay=true
        '';
        ".local/share/applications/davinci-control-panels-setup.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=DaVinci Control Panels Setup
          NoDisplay=true
        '';
        ".local/share/applications/davinci-fairlight-studio-utility.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Fairlight Studio Utility
          NoDisplay=true
        '';
      };
    };

    # Hardware tweaks for DaVinci Resolve on Radeon
    hardware.amdgpu.opencl.enable = lib.mkIf config.module.hardware.radeon.enable true;
  };
}
