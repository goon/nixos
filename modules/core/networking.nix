{ pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    wifi.powersave = true;
  };
  services.resolved.enable = true;
  networking.firewall.enable = true;
  hardware.bluetooth.enable = true;

  environment.systemPackages = [ pkgs.proton-vpn ];
}
