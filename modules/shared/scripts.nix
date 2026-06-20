{
  config,
  lib,
  pkgs,
  repo,
  ...
}:

let
  scriptDir = ../../scripts;

  local-scripts = pkgs.runCommand "local-scripts" { } ''
    mkdir -p $out/bin
    if [ -d ${scriptDir} ]; then
      shopt -s dotglob
      for file in ${scriptDir}/*; do
        if [ "$(basename "$file")" != ".keep" ]; then
          cp -r "$file" $out/bin/
        fi
      done

      if [ -n "$(ls -A $out/bin 2>/dev/null)" ]; then
        chmod +x $out/bin/*
      fi
    fi
    echo ${repo} > $out/dcli.repo
  '';
in
lib.module config "scripts" true {
  userPkgs = [
    local-scripts
  ];
}
