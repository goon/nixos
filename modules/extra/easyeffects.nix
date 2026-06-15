{
  config,
  lib,
  ...
}:

lib.module config "easyeffects" true {
  home = {
    services.easyeffects.enable = true;
  };
}
