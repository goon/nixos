{ config, lib, ... }:

lib.module config "localsend" false {
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };
}
