# ── TREE.NIX ───────────────
# Core DAG dependency resolver for the Dendritic architecture.
# Reads the global module definitions and dynamically extracts dependencies.
{
  lib,
  options,
  ...
}:
let
  modNames = builtins.attrNames options.module;

  # Reverse mapping: file -> module name
  fileToMod = builtins.listToAttrs (
    lib.concatMap (
      m:
      map (decl: {
        name = decl;
        value = m;
      }) options.module.${m}.declarations
    ) modNames
  );

  # Extract dependencies: which module enabled which?
  depsPairs = lib.concatMap (
    m:
    lib.concatMap (
      def:
      # If the module was enabled (value == true)
      # and the file that enabled it corresponds to another module
      # and the module didn't just enable itself (caller != target)
      if def.value == true && builtins.hasAttr def.file fileToMod && fileToMod.${def.file} != m then
        [
          {
            caller = fileToMod.${def.file};
            target = m;
          }
        ]
      else
        [ ]
    ) options.module.${m}.definitionsWithLocations
  ) modNames;

  # Group by caller to build registry: { hyprland = [ "wayland" ]; }
  registry = builtins.foldl' (
    acc: pair: acc // { ${pair.caller} = (acc.${pair.caller} or [ ]) ++ [ pair.target ]; }
  ) { } depsPairs;

  # Find top-level includes by finding files that enabled modules but *aren't* in the module mapping
  # (These are the host default.nix files)
  hostIncludes = lib.concatMap (
    m:
    lib.concatMap (
      def: if def.value == true && !(builtins.hasAttr def.file fileToMod) then [ m ] else [ ]
    ) options.module.${m}.definitionsWithLocations
  ) modNames;

  # Function to build the nested tree structure for visualization
  buildTree =
    targetList: visited:
    builtins.listToAttrs (
      map (target: {
        name = target;
        value =
          if builtins.elem target visited then
            { }
          else if builtins.hasAttr target registry && registry.${target} != [ ] then
            buildTree registry.${target} (visited ++ [ target ])
          else
            { };
      }) targetList
    );
in
{
  # We still define this so nyx tree can read it
  config = {
    system.build.tree = buildTree hostIncludes [ ];
  };
}
