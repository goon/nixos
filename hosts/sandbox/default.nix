{
  imports = [
    ./hardware-configuration.nix
  ];

  module.monitors = true;
  module.virtualisation = true;

  module.dev = true;
  module.fastfetch = true;
  module.firefox = true;
  module.git = true;
  module.kitty = true;
  module.nvf = true;
  module.starship = true;
  module.yazi = true;

  profile.session = true;

  networking.hostName = "sandbox";

  nix.settings = {
    max-jobs = 2;
    cores = 2;
  };

  globals.stateVersion = "25.11";
}
