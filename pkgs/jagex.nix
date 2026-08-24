{
  lib,
  appimageTools,
  fetchurl,
  hicolor-icon-theme,
  zlib,
}:

let
  pname = "jagex-launcher";
  version = "0.1.5";

  src = fetchurl {
    url = "https://rs-launcher-updates.runescape.com/production/linux/x64/latest/jagex-launcher-beta-linux-x86_64.AppImage";
    hash = "sha256-9+pwtK/c1vK8gPb/DPIqjK9dNoVDahMWR4hkkUvfhJs=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = _pkgs: [
    hicolor-icon-theme
    zlib
  ];
  extraBwrapArgs = [ "--setenv APPIMAGE_EXTRACT_AND_RUN 1" ];

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/jagex-launcher.desktop \
      $out/share/applications/jagex-launcher.desktop
    substituteInPlace $out/share/applications/jagex-launcher.desktop \
      --replace-fail 'Exec=AppRun %U' \
      'Exec=env DESKTOPINTEGRATION=false jagex-launcher %U'

    mkdir -p $out/share/icons
    cp -R ${appimageContents}/usr/share/icons/hicolor $out/share/icons/

    install -Dm644 ${appimageContents}/LICENSE.electron.txt \
      $out/share/licenses/''${pname}/LICENSE.electron.txt
    install -Dm644 ${appimageContents}/LICENSES.chromium.html \
      $out/share/licenses/''${pname}/LICENSES.chromium.html
  '';

  meta = {
    description = "Official Jagex Launcher for RuneScape games";
    homepage = "https://www.jagex.com/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
