{
  lib,
  stdenvNoCC,
  fetchurl,
  p7zip,
}:
let
  google-sans-flex = stdenvNoCC.mkDerivation {
    pname = "google-sans-flex";
    version = "0-unstable-2026-09-15";
    src = fetchurl {
      name = "GoogleSansFlex.ttf";
      url = "https://raw.githubusercontent.com/google/fonts/3dc14e61f108f036db84188b9b405a67df9b7c88/ofl/googlesansflex/GoogleSansFlex%5BGRAD,ROND,opsz,slnt,wdth,wght%5D.ttf";
      hash = "sha256-wxpIL77L8uB+aJATTSAHhyOq33Msm5xsmkT4b4Jltv4=";
    };
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      install -Dm444 "$src" "$out/share/fonts/truetype/GoogleSansFlex[GRAD,ROND,opsz,slnt,wdth,wght].ttf"
      runHook postInstall
    '';
    meta = {
      description = "Google Sans Flex variable font family";
      homepage = "https://fonts.google.com/specimen/Google+Sans+Flex";
      license = lib.licenses.ofl;
      platforms = lib.platforms.all;
    };
  };

  appleFont =
    name: def:
    stdenvNoCC.mkDerivation {
      pname = name;
      version = "0-unstable-2026-09-14";
      src = fetchurl { inherit (def) url hash; };
      nativeBuildInputs = [ p7zip ];
      sourceRoot = ".";
      unpackPhase = ''
        runHook preUnpack
        7z x -y "$src" > /dev/null
        find . -name '*.pkg' -exec 7z x -y {} \; > /dev/null
        find . -name 'Payload~' -exec 7z x -y -tcpio {} \; > /dev/null
        runHook postUnpack
      '';
      installPhase = ''
        runHook preInstall
        mkdir -p "$out/share/fonts/truetype"
        ${lib.concatMapStrings (pattern: ''
          find . -name '${pattern}' -exec install -Dm644 -t "$out/share/fonts/truetype" {} +
        '') def.include}
        if [ -z "$(ls -A "$out/share/fonts/truetype")" ]; then
          echo "no fonts matched ${lib.concatStringsSep ", " def.include}" >&2
          exit 1
        fi
        runHook postInstall
      '';
      meta = {
        description = "Apple ${name} font family";
        homepage = "https://developer.apple.com/fonts/";
        license = lib.licenses.unfree;
        platforms = lib.platforms.all;
      };
    };

  base = "https://devimages-cdn.apple.com/design/resources/download";
  appleDefs = {
    sf-pro = {
      url = "${base}/SF-Pro.dmg";
      hash = "sha256-loqzuLH5LC2K9h6waA9cIiTE541ZuYa/AEUCp/wBKRg=";
      include = [
        "SF-Pro.ttf"
        "SF-Pro-Italic.ttf"
      ];
    };
    sf-compact = {
      url = "${base}/SF-Compact.dmg";
      hash = "sha256-wdDjROut1m62LwP4I3hMzknxeH9WVj+wmPygH8VUE1w=";
      include = [
        "SF-Compact.ttf"
        "SF-Compact-Italic.ttf"
      ];
    };
    sf-mono = {
      url = "${base}/SF-Mono.dmg";
      hash = "sha256-bUoLeOOqzQb5E/ZCzq0cfbSvNO1IhW1xcaLgtV2aeUU=";
      include = [ "SF-Mono-*.otf" ];
    };
    ny = {
      url = "${base}/NY.dmg";
      hash = "sha256-HC7ttFJswPMm+Lfql49aQzdWR2osjFYHJTdgjtuI+PQ=";
      include = [
        "NewYork.ttf"
        "NewYorkItalic.ttf"
      ];
    };
  };
in
{
  inherit google-sans-flex;
}
// lib.mapAttrs appleFont appleDefs
