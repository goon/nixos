{ pkgs, inputs, fonts, ... }:

let
  voidTheme = pkgs.stdenv.mkDerivation {
    name = "sddm-void-theme";
    src = inputs.voidsddm;
    installPhase = ''
            mkdir -p $out/share/sddm/themes/voidsddm
            cp -r $src/* $out/share/sddm/themes/voidsddm/
            chmod -R u+w $out/share/sddm/themes/voidsddm
            
            # Override config with custom font
            cat > $out/share/sddm/themes/voidsddm/configs/nixos.conf <<'EOF'
      [General]
      # Background color
      background=#000000
      # Background image (leave empty to use background color)
      backgroundImage=

      # Text color
      textColor=#c4c4c4
      # Font family (matching terminal font)
      fontFamily=${fonts.monospace}

      # Password field
      passwordFieldWidth=220
      passwordFieldHeight=40
      passwordFieldMargin=20
      passwordFieldFontSize=16
      passwordFieldLetterSpacing=1
      passwordFieldBackground=#333333
      passwordFieldBorder=#888888
      passwordFieldBorderActive=#aaaaaa
      passwordFieldBorderWidth=1
      passwordFieldBorderWidthActive=2
      passwordFieldRadius=16
      # Empty for default circle ●
      passwordCharacter=
      showPasswordButton=false

      # UI Offset
      passwordFieldOffsetX=0
      passwordFieldOffsetY=50

      # Selectors
      selectorSpacing=10
      selectorFontSize=14
      selectorArrowFontSize=17
      selectorHeight=35
      selectorArrowWidth=30
      selectorRadius=10

      showSelectorPreview=true
      selectorPreviewFontSize=13
      selectorPreviewColor=#666666
      selectorPreviewMargin=10

      # Animation duration (milliseconds)
      animationDuration=200
      # you probably wont see it if its below 1000
      fadeInDuration=1000

      # Spacing
      elementSpacing=15

      # Global opacity for all elements
      elementOpacity=1.0

      # Cursor
      showCursor=false

      # Help tips
      showHelpTips=false
      helpTipsFontSize=11
      helpTipsColor=#666666

      # Caps Lock indicator
      showCapsLockIndicator=true
      capsLockIndicatorColor=#ffaa00
      capsLockIndicatorFontSize=12

      # Login error
      loginErrorColor=#ff3117
      loginErrorShake=true
      loginErrorBorderWidth=4
      # Delay in milliseconds before checking if login failed
      loginErrorDelay=500

      # Password validation
      allowEmptyPassword=false
      # Clear password field on login error
      clearPasswordOnError=true

      # Clock
      showClock=false
      clockOffsetX=0
      clockOffsetY=-180
      clockFontFamily=${fonts.monospace}
      clockFontSize=50
      clockColor=#c4c4c4
      # Clock format placeholders:
      # %h - 12 hour format without leading zero (9)
      # %H - 24 hour format with leading zero (09)
      # %m - minutes without leading zero (9)
      # %M - minutes with leading zero (09)
      # %s - seconds without leading zero (3)
      # %S - seconds with leading zero (09)
      clockFormat=%H:%M
      EOF

            # Update metadata.desktop to use the custom config
            sed -i 's/ConfigFile=configs\/default.conf/ConfigFile=configs\/nixos.conf/' $out/share/sddm/themes/voidsddm/metadata.desktop
    '';
  };
in
{
  # Enable SDDM display manager
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    wayland.enable = true;
    theme = "voidsddm";
    settings = {
      General = {
        DisplayServer = "wayland";
      };
    };
  };

  # Install the theme
  environment.systemPackages = [ voidTheme ];
}
