# ── INCLUDES.NIX ───────────────
# Core DAG dependency resolver for the Dendritic architecture.
# Reads the global module registry and dynamically resolves nested includes.

{ config, lib, ... }:

let
  inherit (lib) types mkOption;

  # The raw list of top-level includes defined in the host
  hostIncludes = config.includes;

  # The global registry containing every module's dependencies
  registry = config.dendritic.registry;

  # Recursive function to walk the DAG
  # Returns a list of all required modules (including dependencies)
  resolveIncludes =
    targetList: visited:
    let
      processTarget =
        target: currentVisited:
        if builtins.elem target currentVisited then
          currentVisited # Avoid circular dependencies / diamond problem
        else
          let
            # Hard error if the included module does not exist in the registry

            deps = registry.${target} or [ ];

            # Recurse into dependencies first
            visitedWithDeps = builtins.foldl' (
              acc: dep: if builtins.elem dep acc then acc else processTarget dep acc
            ) (currentVisited ++ [ target ]) deps;

          in
          visitedWithDeps;
    in
    builtins.foldl' (acc: target: processTarget target acc) visited targetList;

  # The flattened, deduplicated list of all modules that should be enabled
  resolvedModules = resolveIncludes hostIncludes [ ];

  # Function to build the nested tree structure for visualization
  buildTree =
    targetList:
    builtins.listToAttrs (
      map (target: {
        name = target;
        value =
          if builtins.hasAttr target registry && registry.${target} != [ ] then
            buildTree registry.${target}
          else
            { };
      }) targetList
    );

in
{
  options = {
    # The top-level array you use in your hosts/desktop/default.nix
    includes = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of top-level modules/profiles to include for this host.";
    };

    # The internal dictionary where every module registers its dependencies
    dendritic.registry = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = { };
      description = "Global registry of all modules and their includes.";
    };
  };

  config = {
    # 1. Automatically enable all modules that were resolved in the DAG
    module = builtins.listToAttrs (
      map (mod: {
        name = mod;
        value = true;
      }) resolvedModules
    );

    # 2. Expose the raw tree to NixOS so the `nyx includes` script can read it
    system.build.includes = buildTree hostIncludes;
  };
}
