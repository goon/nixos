# lib/module.nix
# Core architecture engine for the dendritic module system.
# Wraps module definitions with automatic enable options, home-manager wiring, and package lists.

{ lib }:

lib.extend (
  final: _prev: {
    module =
      config: name: defaultState: body:
      let
        isAdvanced = body ? options || body ? config || body ? home || body ? sysPkgs || body ? userPkgs;

        extraOptions = if isAdvanced then (body.options or { }) else { };
        baseConfig = if isAdvanced then (body.config or { }) else body;

        hasHome = body ? home;
        hasSysPkgs = body ? sysPkgs;
        hasUserPkgs = body ? userPkgs;

        hmSharedModule =
          if hasHome || hasUserPkgs then
            {
              home-manager.sharedModules = [
                (if hasHome then body.home else { })
                (if hasUserPkgs then { home.packages = body.userPkgs; } else { })
              ];
            }
          else
            { };

        sysPkgsConfig = if hasSysPkgs then { environment.systemPackages = body.sysPkgs; } else { };

        rawConfig = final.mkMerge [
          baseConfig
          hmSharedModule
          sysPkgsConfig
        ];
      in
      {
        options = final.recursiveUpdate extraOptions {
          module.${name}.enable = final.mkEnableOption name // {
            default = defaultState;
          };
        };
        config = final.mkIf config.module.${name}.enable rawConfig;
      };
  }
)
