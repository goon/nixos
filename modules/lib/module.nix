{ lib }:

lib.extend (final: prev: {
  module =
    config: name: defaultState: body:
    {
      options.module.${name}.enable = final.mkEnableOption name // {
        default = defaultState;
      };
      config = final.mkIf config.module.${name}.enable body;
    };
})
