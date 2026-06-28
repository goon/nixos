{
  flakePath ? null,
  hostnamePath ? "/etc/hostname",
}:
let
  inherit (builtins) getFlake head match currentSystem readFile pathExists;

  flakePath' = toString (
    if flakePath != null then
      flakePath
    else
      ../.
  );

  flake = if pathExists flakePath' then getFlake flakePath' else { };
  
  hostname =
    if pathExists hostnamePath then head (match "([a-zA-Z0-9\\-]+)\n" (readFile hostnamePath)) else "";

  system = currentSystem;
  nixpkgs = if flake ? inputs && flake.inputs ? nixpkgs then flake.inputs.nixpkgs else null;
  pkgs = if nixpkgs != null then import nixpkgs { inherit system; } else { };

  nixpkgsOutput = removeAttrs (pkgs // pkgs.lib or { }) [
    "options"
    "config"
  ];
in
{
  inherit flake pkgs;
}
// flake
// builtins
// (flake.nixosConfigurations or { })
// flake.nixosConfigurations.${hostname} or { }
// nixpkgsOutput
// {
  getFlake = path: getFlake (toString path);
}
