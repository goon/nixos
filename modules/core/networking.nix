{ pkgs, ... }:

{
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  hardware.bluetooth.enable = true;

  environment.systemPackages = [ pkgs.proton-vpn ];
}
