# ── OVERLAYS.NIX ──────────────
# Helpers for self-authored nixpkgs overlays with self-expiring warnings.
# pinOlder: pin a package to an older version for any reason, with a caller-
#           supplied condition that fires a warning when the override may be
#           obsolete.
# unbreakWithWarning: force a package to be considered unbroken and warn
#                      when upstream marks it unbroken naturally.
{ lib }:
{
  pinOlder =
    {
      pname,
      version,
      sha256,
      sourceArgs ? { },
      condition,
    }:
    drv:
    lib.warnIf (condition drv)
      ''
        ${pname} override may now be obsolete (nixpkgs: ${drv.version}).
        Review and remove the override from overlays/${pname}.nix.
      ''
      drv.overrideAttrs
      (_: {
        inherit version;
        src = lib.fetchurl (
          sourceArgs
          // {
            urls = sourceArgs.urls or [ "https://example.invalid/${pname}-${version}.tar.gz" ];
            inherit sha256;
          }
        );
      });

  unbreakWithWarning =
    drv:
    lib.warnIfNot (drv.meta.broken or false)
      ''
        ${drv.pname or drv.name} is no longer marked broken in nixpkgs — the override can be removed.
      ''
      drv.overrideAttrs
      (old: {
        meta = old.meta // {
          broken = false;
        };
      });
}
