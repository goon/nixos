{
  config,
  lib,
  ...
}:
lib.module config "easyeffects" false {
  homeManager = {
    services.easyeffects.enable = true;
  };
}
