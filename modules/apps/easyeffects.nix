{
  config,
  lib,
  ...
}:

lib.module config "easyeffects" false {
  home = {
    services.easyeffects.enable = true;
  };
}
