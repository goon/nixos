# ── MODULE.NIX ───────────────
# Core architecture engine for the dendritic module system.
# Wraps module definitions with automatic boolean enable options,
# home-manager wiring, and handles conditional evaluation based on host dashboards.

{ lib }:
lib.extend (
  final: _prev: {
    module =
      config: name: defaultState: body:
      let
        isAdvanced = body ? options || body ? config || body ? homeManager || body ? includes;

        extraOptions = if isAdvanced then (body.options or { }) else { };
        baseConfig = if isAdvanced then (body.config or { }) else body;
        moduleIncludes = if isAdvanced then (body.includes or [ ]) else [ ];

        # Extract imports so they are evaluated unconditionally
        extraImports = baseConfig.imports or [ ];
        cleanConfig = removeAttrs baseConfig [
          "imports"
          "includes"
        ];

        hasHomeManager = body ? homeManager;

        hmSharedModule =
          if hasHomeManager then
            {
              home-manager.sharedModules = [ body.homeManager ];
            }
          else
            { };

        rawConfig = final.mkMerge [
          cleanConfig
          hmSharedModule
        ];
      in
      {
        imports = extraImports;
        options = final.recursiveUpdate extraOptions {
          module.${name} = final.mkEnableOption name // {
            default = defaultState;
          };
        };
        config = final.mkMerge [
          (final.mkIf config.module.${name} rawConfig)
          { dendritic.registry.${name} = moduleIncludes; }
        ];
      };
  }
)
