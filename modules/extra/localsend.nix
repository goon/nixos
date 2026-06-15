{ config, lib, ... }:

lib.module config "localsend" true {
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };
}
