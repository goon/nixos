{ config, lib, ... }:

# We use your lib.module wrapper to name it "profiles.session"
lib.module config "profile.session" false {

  # We just pass the names of the modules we want!
  includes = [
    "hyprland"
    "gtk"
    "qt"
    "quickshell"
    "wayland"
    "xdg"
  ];
}
