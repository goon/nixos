{
  lib,
  appimageTools,
  fetchurl,
  hicolor-icon-theme,
  zlib,
}:

let
  pname = "openchamber";
  version = "2.1.0";

  src = fetchurl {
    url = "https://github.com/openchamber/openchamber/releases/download/v${version}/OpenChamber-${version}-linux-x86_64.AppImage";
    hash = "sha256-q08g/HwXzLy+cgz8u7q9C1ksGdjn6+BmPXyz+RiggvI=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = _pkgs: [
    hicolor-icon-theme
    zlib
  ];
  extraBwrapArgs = [ "--setenv APPIMAGE_EXTRACT_AND_RUN 1" ];

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/openchamber.desktop \
      $out/share/applications/openchamber.desktop
    substituteInPlace $out/share/applications/openchamber.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' \
      'Exec=openchamber --no-sandbox %U'

    mkdir -p $out/share/icons
    cp -R ${appimageContents}/usr/share/icons/hicolor $out/share/icons/

    install -Dm644 ${appimageContents}/LICENSE.electron.txt \
      $out/share/licenses/openchamber/LICENSE.electron.txt
    install -Dm644 ${appimageContents}/LICENSES.chromium.html \
      $out/share/licenses/openchamber/LICENSES.chromium.html
  '';

  meta = {
    description = "Desktop workspace for running and reviewing AI coding work";
    homepage = "https://github.com/openchamber/openchamber";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
