_:

{
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.dbus.implementation = "broker";
}
