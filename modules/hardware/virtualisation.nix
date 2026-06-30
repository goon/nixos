{
  config,
  lib,
  ...
}:
lib.module config "virtualisation" false {
  config = {
    virtualisation.vmware.guest.enable = true;

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER_ALLOW_SOFTWARE = "1";
      LIBGL_ALWAYS_SOFTWARE = "1";
      GALLIUM_DRIVER = "llvmpipe";
    };
  };
}
