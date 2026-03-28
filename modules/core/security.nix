{ pkgs, ... }:

{
  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    polkit_gnome
  ];
}
