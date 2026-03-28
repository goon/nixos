import QtQuick
import qs.services
pragma Singleton

QtObject {
    id: root

    // Bind to the active theme palette from ThemeService
    readonly property var activePalette: ThemeService.currentColors
    // Scaling factor for Bar elements based on Density setting
    readonly property real barScale: {
        if (Preferences.barDensity === 0)
            return 0.9;
 // Compact
        if (Preferences.barDensity === 1)
            return 1;
 // Default
        if (Preferences.barDensity === 2)
            return 1.1;
 // Comfortable
        return 1;
    }
    /*
     * =========================================================================
     *   🌈 SEMANTIC COLORS (UI Roles)
     *   Mirrors the flat semantic structure used in theme assets
     * =========================================================================
     */
    readonly property QtObject base16: QtObject {
        // --- Backgrounds & Surfaces ---
        readonly property color base00: root.activePalette.base00 || "#16161D" // Default App Background
        readonly property color base01: root.activePalette.base01 || "#1F1F28" // Lighter Background (Panels, Status Bars)
        readonly property color base02: root.activePalette.base02 || "#2A2A37" // Selection Background / Hover States
        readonly property color base03: root.activePalette.base03 || "#363646" // Inactive Elements / Borders / Comments
        
        // --- Foregrounds & Text ---
        readonly property color base04: root.activePalette.base04 || "#54546D" // Muted Text / Dark Foreground
        readonly property color base05: root.activePalette.base05 || "#DCD7BA" // Default Foreground / Standard Text
        readonly property color base06: root.activePalette.base06 || "#C8C093" // Light Foreground / Emphasized Text
        readonly property color base07: root.activePalette.base07 || "#E8E5DF" // Brightest Foreground / Active Text

        // --- Brand & Feedback Colors ---
        readonly property color base08: root.activePalette.base08 || "#E82424" // Red: Error, Destructive Actions
        readonly property color base09: root.activePalette.base09 || "#FF9E3B" // Orange: Warning, Alerts
        readonly property color base0A: root.activePalette.base0A || "#E6C384" // Yellow: Accent, Highlights
        readonly property color base0B: root.activePalette.base0B || "#76946A" // Green: Success, Positive States
        readonly property color base0C: root.activePalette.base0C || "#7AA89F" // Cyan: Info, Active Indicators
        readonly property color base0D: root.activePalette.base0D || "#7E9CD8" // Blue: Primary Brand Color, Links
        readonly property color base0E: root.activePalette.base0E || "#957FB8" // Purple/Magenta: Secondary Brand Color
        readonly property color base0F: root.activePalette.base0F || "#DCA561" // Brown: Tertiary Colors, Misc
    }

    readonly property QtObject
    colors: QtObject {
        // --- Surfaces and Backgrounds ---
        readonly property color appBackground: base16.base00
        readonly property color panelBackground: base16.base01
        readonly property color elementBackground: base16.base02
        
        // --- Borders and Dividers ---
        readonly property color border: base16.base03
        readonly property color divider: base16.base02
        
        // --- Typography ---
        readonly property color textMuted: base16.base04
        readonly property color text: base16.base05
        readonly property color textLight: base16.base06
        readonly property color textLighter: base16.base07
        
        // --- Branding & Gradients ---
        readonly property color primary: root.activePalette.primaryIdx ? base16[root.activePalette.primaryIdx] : base16.base0D
        readonly property color secondary: root.activePalette.secondaryIdx ? base16[root.activePalette.secondaryIdx] : base16.base0E
        readonly property color accent: base16.base0A

        // --- Feedback & Alerts ---
        readonly property color success: base16.base0B
        readonly property color warning: base16.base09
        readonly property color error: base16.base08
        readonly property color info: base16.base0C

        // --- Backward Compatibility Aliases ---
        readonly property color base: appBackground
        readonly property color background: panelBackground
        readonly property color surface: elementBackground
        readonly property color muted: textMuted

        // --- Helpers ---
        readonly property color transparent: "transparent"
    }

    readonly property QtObject blur: QtObject {
        readonly property real backgroundOpacity: Math.max(0.3, Preferences.blurOpacity)
        readonly property real surfaceOpacity: Math.max(0.3, Preferences.blockOpacity)
    }

    /*
     * =========================================================================
     *   📐 GEOMETRY (Style Tokens)
     * =========================================================================
     */
    readonly property QtObject
    geometry: QtObject {
        readonly property int radius: Preferences.cornerRadius
        readonly property QtObject
        spacing: QtObject {
            readonly property int small: 6
            readonly property int medium: 8
            readonly property int large: 12
            // Increased scaling for padding to prevent text clipping at high radiuses
            readonly property int dynamicPadding: Math.max(20, Math.ceil(root.geometry.radius * 0.5))
        }

        readonly property int barMarginTop: 10
        readonly property int barMarginSide: 10
        readonly property int barPanelGap: 2
    }

    /*
     * =========================================================================
     *   📏 DIMENSIONS (Component Sizing)
     * =========================================================================
     */
    readonly property QtObject
    dimensions: QtObject {
        readonly property int barItemHeight: 32
        readonly property int iconSmall: 14
        readonly property int iconBase: 18
        readonly property int iconMedium: 22
        readonly property int iconLarge: 32
        readonly property int iconExtraLarge: 48
        readonly property int toastWidth: 400
        readonly property int launcherWidth: 600
        readonly property int panelWidth: 400
        readonly property int trayMenuWidth: 220
        readonly property int calendarCellSize: 40
        readonly property int calendarBlockWidth: 320
        readonly property int launcherItemHeight: 54
        readonly property int launcherSearchHeight: 50
        readonly property QtObject
        workspace: QtObject {
            readonly property int pillWidth: 36
            readonly property int pillHeight: 15
        }

    }

    /*
     * =========================================================================
     *   🔡 TYPOGRAPHY
     * =========================================================================
     */
    readonly property QtObject
    typography: QtObject {
        readonly property string family: Preferences.shellFont
        readonly property string iconFamily: "Material Symbols Rounded"
        readonly property QtObject
        weights: QtObject {
            readonly property int normal: 400
            readonly property int medium: 500
            readonly property int bold: 700
        }

        readonly property QtObject
        size: QtObject {
            readonly property int small: 10
            readonly property int base: 12
            readonly property int medium: 14
            readonly property int large: 16
            readonly property int display: 48
        }

    }

    readonly property FontLoader
    iconFont: FontLoader {
        source: Qt.resolvedUrl("../assets/fonts/MaterialSymbolsRounded.ttf")
    }

    /*
     * =========================================================================
     *   🎬 ANIMATIONS & EFFECTS
     * =========================================================================
     */
    readonly property QtObject
    animations: QtObject {
        readonly property int fast: 250
        readonly property int normal: 450
        readonly property int slow: 700
        readonly property int easingType: Easing.OutQuint
        readonly property var bezierCurve: [0.15, 0, 0, 1]
    }

    readonly property QtObject
    effects: QtObject {
        readonly property QtObject
        shadow: QtObject {
            readonly property color color: colors.base
            readonly property int radius: 20
            readonly property int samples: 20
            readonly property int offsetX: 0
            readonly property int offsetY: 0
        }

        readonly property int mediaPlayerBlurRadius: 10
    }

    function alpha(c, a) {
        if (!c)
            return "transparent";

        return Qt.rgba(c.r, c.g, c.b, a);
    }

}
