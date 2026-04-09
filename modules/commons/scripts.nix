{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;

  # Reference to the scripts directory relative to this file
  scriptDir = ../scripts;

  # Create a package containing all scripts in modules/scripts/
  # We use runCommand to copy them and ensure they are executable.
  local-scripts = pkgs.runCommand "local-scripts" { } ''
    mkdir -p $out/bin
    if [ -d ${scriptDir} ]; then
      # Only copy if there are files (excluding .keep)
      shopt -s dotglob
      for file in ${scriptDir}/*; do
        if [ "$(basename "$file")" != ".keep" ]; then
          cp -r "$file" $out/bin/
        fi
      done
      
      # Ensure everything in bin is executable
      if [ -n "$(ls -A $out/bin 2>/dev/null)" ]; then
        chmod +x $out/bin/*
      fi
    fi
  '';
in
{
  options.module.scripts.enable = mkEnableOption "scripts/ manager" // {
    default = true;
  };

  config = mkIf config.module.scripts.enable {
    home-manager.users.${username} = {
      home.packages = [
        local-scripts
      ];
    };
  };
}
