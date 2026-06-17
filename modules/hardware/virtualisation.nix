{ config, lib, ... }:

lib.module config "virtualisation" true {
  config = {
    virtualisation.vmware.guest.enable = true;

    # Required for Hyprland and hardware-accelerated apps (like Kitty) to work in a VM environment
    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER_ALLOW_SOFTWARE = "1";
      LIBGL_ALWAYS_SOFTWARE = "1";
      GALLIUM_DRIVER = "llvmpipe";
    };
  };
}
