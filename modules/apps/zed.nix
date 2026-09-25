{
  config,
  lib,
  ...
}:
lib.module config "zed" false {
  homeManager = {
    programs.zed-editor.enable = true;
  };
}
