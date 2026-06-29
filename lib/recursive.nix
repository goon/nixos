# ── RECURSIVE.NIX ────────────
# Helper function that recursively traverses the modules/ directory.
# Finds all valid .nix files and returns them as a flat list of paths
# to be natively ingested by the NixOS module system.
dir:
let
  recurse =
    path:
    let
      dirContents = builtins.readDir path;
      names = builtins.attrNames dirContents;

      processItem =
        name:
        let
          type = dirContents.${name};
          fullPath = path + ("/" + name);

          isPrivate =
            let
              firstChar = builtins.substring 0 1 name;
            in
            firstChar == "_" || firstChar == ".";

          isNixFile =
            let
              len = builtins.stringLength name;
            in
            len > 4 && builtins.substring (len - 4) 4 name == ".nix" && name != "default.nix" && !isPrivate;
        in
        if type == "directory" then
          if isPrivate then
            [ ]
          else if builtins.pathExists (fullPath + "/default.nix") then
            [ (fullPath + "/default.nix") ]
          else
            recurse fullPath
        else if (type == "regular" || type == "symlink") && isNixFile then
          [ fullPath ]
        else
          [ ];
    in
    builtins.concatLists (map processItem names);
in
recurse dir
