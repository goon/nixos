{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
  alsa-lib,
  atk,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  hicolor-icon-theme,
  krb5,
  libdrm,
  libgbm,
  libGL,
  libglvnd,
  libice,
  libpulseaudio,
  libsecret,
  libsm,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxmu,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxt,
  libxtst,
  mesa,
  nspr,
  nss,
  pango,
  pciutils,
  pipewire,
  systemd,
  vulkan-loader,
  wayland,
  zlib,
}:

let
  pname = "wfhelper";
  version = "2.1.1";

  src = fetchurl {
    url = "https://github.com/WFHelper/WFHelper/releases/download/v${version}/WFHelper-${version}.AppImage";
    hash = "sha256-04lf525fLcWC9yI6Bw4PZn0MUZNUfKrypvVqfoCvRdM=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };

  libs = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    hicolor-icon-theme
    krb5
    libdrm
    libgbm
    libGL
    libglvnd
    libice
    libpulseaudio
    libsecret
    libsm
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxmu
    libxrandr
    libxrender
    libxscrnsaver
    libxt
    libxtst
    mesa
    nspr
    nss
    pango
    pciutils
    pipewire
    stdenv.cc.cc.lib
    systemd
    vulkan-loader
    wayland
    zlib
  ];
in
stdenv.mkDerivation {
  inherit pname version;
  src = appimageContents;
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = libs;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/wfhelper $out/bin $out/share/applications
    cp -r $src/* $out/share/wfhelper/
    chmod +x $out/share/wfhelper/wfhelper

    install -Dm644 $src/wfhelper.desktop \
      $out/share/applications/wfhelper.desktop
    substituteInPlace $out/share/applications/wfhelper.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' \
      'Exec=wfhelper %U'

    mkdir -p $out/share/icons
    cp -R $src/usr/share/icons/hicolor $out/share/icons/

    install -Dm644 $src/LICENSE.electron.txt \
      $out/share/licenses/${pname}/LICENSE.electron.txt
    install -Dm644 $src/LICENSES.chromium.html \
      $out/share/licenses/${pname}/LICENSES.chromium.html

    mkdir -p $out/share/wfhelper
    cat > $out/share/wfhelper/resolve-ee-log.sh <<'''EOF'''
    if [ -z "$WFHELPER_EE_LOG" ]; then
      _wfh_roots=""
      for _wfh_yml in "$HOME/.local/share/bottles/data.yml" "$HOME/.var/app/com.usebottles.bottles/data/bottles/data.yml"; do
        [ -r "$_wfh_yml" ] || continue
        _wfh_p=$(sed -n "s/^[[:space:]]*custom_bottles_path:[[:space:]]*//p" "$_wfh_yml" 2>/dev/null | head -n 1 | xargs)
        [ -n "$_wfh_p" ] && [ -d "$_wfh_p" ] && _wfh_roots="$_wfh_roots $_wfh_p"
      done
      for _wfh_root in $_wfh_roots "$HOME/.local/share/bottles/bottles" "$HOME/.var/app/com.usebottles.bottles/data/bottles/bottles"; do
        [ -d "$_wfh_root" ] || continue
        for _wfh_log in "$_wfh_root"/*/drive_c/users/*/AppData/Local/Warframe/EE.log; do
          [ -f "$_wfh_log" ] || continue
          if [ -z "$WFHELPER_EE_LOG" ] || [ "$_wfh_log" -nt "$WFHELPER_EE_LOG" ]; then
            export WFHELPER_EE_LOG="$_wfh_log"
          fi
        done
      done
      unset _wfh_roots _wfh_yml _wfh_p _wfh_root _wfh_log
    fi
    EOF
    makeWrapper $out/share/wfhelper/wfhelper $out/bin/wfhelper \
      --add-flags --no-sandbox \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libs}" \
      --run "source $out/share/wfhelper/resolve-ee-log.sh"

    runHook postInstall
  '';

  meta = {
    description = "Unofficial Warframe companion: inventory, relic and riven scanning, market orders";
    homepage = "https://wfhelper.com";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
