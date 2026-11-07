{
  lib,
  pkgs,
}:
let
  buildLibs = with pkgs; [
    mpv-unwrapped
    openssl
    systemd
    dbus
    gtk3
    gdk-pixbuf
    cairo
    glib
    webkitgtk_4_1
    libsoup_3
    stdenv.cc.cc.lib
  ];
  runtimeLibs = with pkgs; [
    libayatana-appindicator
    libGL
    libglvnd
    vulkan-loader
  ];
  gstPlugins = with pkgs.gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-libav
  ];
in
pkgs.stdenv.mkDerivation {
  pname = "harbor";
  version = "1.0.2-beta-1";

  src = pkgs.fetchurl {
    url = "https://github.com/Thunderhawkk/harbor-linux/releases/download/v1.0.2-beta/Harbor_1.0.2-beta-1_amd64.deb";
    hash = "sha256-YydK0g/IWia0mKUbG0dNCArRm2uARqrRUd2LszpJN7M=";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = buildLibs ++ runtimeLibs ++ gstPlugins;
  runtimeDependencies = runtimeLibs;
  dontWrapGApps = true;

  unpackPhase = "runHook preUnpack; dpkg-deb -x \"$src\" .; runHook postUnpack";
  installPhase = "runHook preInstall; mkdir -p $out; cp -r usr/. $out/; runHook postInstall";

  postFixup = ''
    wrapProgram "$out/bin/harbor" \
      "''${gappsWrapperArgs[@]}" \
      --set GIO_MODULE_DIR "${pkgs.glib-networking}/lib/gio/modules" \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${lib.makeSearchPath "lib/gstreamer-1.0" gstPlugins}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath (buildLibs ++ runtimeLibs)}" \
      --prefix PATH : "${
        lib.makeBinPath [
          pkgs.ffmpeg
          pkgs.yt-dlp
        ]
      }"
  '';

  meta = {
    description = "Harbor - community continuation of the Harbor Stremio client";
    homepage = "https://github.com/Harborofficial/Harbor";
    license = lib.licenses.mit;
    mainProgram = "harbor";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = lib.sourceTypes.binaryNativeCode;
  };
}
