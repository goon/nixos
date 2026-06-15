{ lib }:

lib.extend (final: prev: {
  module =
    config: name: defaultState: body:
    let
      isAdvanced = body ? options || body ? config;
      extraOptions = if isAdvanced then (body.options or { }) else { };
      rawConfig = if isAdvanced then (body.config or { }) else body;
    in
    {
      options = extraOptions // {
        module.${name}.enable = final.mkEnableOption name // {
          default = defaultState;
        };
      };
      config = final.mkIf config.module.${name}.enable rawConfig;
    };
})
