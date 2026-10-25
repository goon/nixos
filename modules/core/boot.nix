{ pkgs, ... }: {
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_zen;

    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "loglevel=3"
    ];
  };
}
