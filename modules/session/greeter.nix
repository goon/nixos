{
  config,
  lib,
  ...
}:
lib.module config "greeter" false {
  config = {
    services.displayManager.ly = {
      enable = true;
      settings = {
        animate = true;
        animation = "colormix";
        bg = 0;
        fg = 7;
      };
    };

    console.colors = [
      "11111b" # 00: Base
      "f38ba8" # 01: Red
      "a6e3a1" # 02: Green
      "f9e2af" # 03: Yellow
      "89b4fa" # 04: Blue
      "f5c2e7" # 05: Pink
      "94e2d5" # 06: Teal
      "bac2de" # 07: Subtext1
      "313244" # 08: Surface
      "f38ba8" # 09: Red
      "a6e3a1" # 10: Green
      "f9e2af" # 11: Yellow
      "89b4fa" # 12: Blue
      "f5c2e7" # 13: Pink
      "94e2d5" # 14: Teal
      "a6adc8" # 15: Subtext0
    ];
  };
}
