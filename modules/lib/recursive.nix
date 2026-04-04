# modules/lib/recursive.nix
# A helper function that recursively finds all .nix files in a directory
# and returns them as a list of paths for the 'imports' attribute.

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

          # Check if the name suggests a private or hidden file/directory
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
          if name == "lib" || isPrivate then
            [ ] # Skip forbidden directories
          else if builtins.pathExists (fullPath + "/default.nix") then
            [ (fullPath + "/default.nix") ]
          else
            recurse fullPath
        # Support regular files and symlinks that point to nix files
        else if (type == "regular" || type == "symlink") && isNixFile then
          [ fullPath ]
        else
          [ ];
    in
    builtins.concatLists (map processItem names);
in
recurse dir
