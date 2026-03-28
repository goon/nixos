import QtQuick
import Quickshell
import Quickshell.Io
import qs
pragma Singleton

QtObject {
    id: root

    property bool loaded: false
    property int notificationMode: 0 // 0: Normal, 1: DND (Silent)
    property double desktopDim: 0.25 // 0.0 to 1.0 (Opacity)
    property string weatherLat: "51.50853"
    property string weatherLong: "-0.12574"
    property string weatherLocationName: "London, England, United Kingdom"
    property bool weatherShowLocation: true
    property bool gowallEnabled: false // Global Toggle
    property bool blurEnabled: false
    property double blurOpacity: 0.5
    property double blockOpacity: 0.7
    property double themedAppsOpacity: 1.0
    // Theme Configuration
    property string currentTheme: "solaris"
    property string themeMode: "dark"
    // Bar Configuration
    property string barPosition: "top"
    property string shellFont: "Outfit Medium"
    property int barDensity: 1 // 0: Compact, 1: Default, 2: Comfortable
    property int notificationDensity: 1 // 0: Compact, 1: Comfortable
    property int workspaceStyle: 0 // 0: Arabic, 1: Roman, 2: Kanji

    // State Persistence (Shared with Theme/Wallpaper services)
    property var currentThemeColors: ({})
    property string currentWallpaper: ""

    property int barHeight: 55
    property int barMarginTop: 10
    property int barMarginSide: 10
    property int cornerRadius: 28
    property int popoutMargin: 8
    property bool barFitToContent: true
    property var barLeftComponents: []
    property var barCenterComponents: ["workspaces", "dock", "stats", "tray", "volume", "systemControl", "notifications", "clock"]
    property var barRightComponents: []
    property var themedApps: ({
        "gtk": false,
        "kitty": false,
        "vesktop": false,
        "obsidian": false,
        "nvim": false,
        "firefox": false,
        "gowall": true,
        "steam": false,
        "qt6ct": false
    })

    // Functional Configuration
    property string webSearchUrl: Config.webSearchUrl
    property string terminal: Config.terminal
    property string wallpaperDirectory: ""
    property bool wallpaperParallaxEnabled: false
    property int wallpaperParallaxStrength: 20
    
    // Presets Configuration
    property var presets: ({})

    readonly property string prefsFile: Config.prefsFile
    // Native file reading for preferences
    property FileView prefsFileView
    // Safety fallback: if file doesn't exist or load fails, assume defaults and enable saving
    property Timer safetyTimer


    // Save settings to disk (Internal debounced call)
    function save() {
        if (!loaded)
            return ;

        var data = {
            "notificationMode": root.notificationMode,
            "desktopDim": root.desktopDim,
            "weatherLat": root.weatherLat,
            "weatherLong": root.weatherLong,
            "weatherLocationName": root.weatherLocationName,
            "weatherShowLocation": root.weatherShowLocation,
            "gowallEnabled": root.gowallEnabled,
            "blurEnabled": root.blurEnabled,
            "blurOpacity": root.blurOpacity,
            "blockOpacity": root.blockOpacity,
            "themedAppsOpacity": root.themedAppsOpacity,
            "currentTheme": root.currentTheme,
            "themeMode": root.themeMode,
            "barPosition": root.barPosition,
            "shellFont": root.shellFont,
            "barDensity": root.barDensity,
            "notificationDensity": root.notificationDensity,
            "barHeight": root.barHeight,

            "barMarginTop": root.barMarginTop,
            "barMarginSide": root.barMarginSide,
            "cornerRadius": root.cornerRadius,
            "popoutMargin": root.popoutMargin,
            "barFitToContent": root.barFitToContent,
            "barLeftComponents": root.barLeftComponents,
            "barCenterComponents": root.barCenterComponents,
            "barRightComponents": root.barRightComponents,
            "themedApps": root.themedApps,
            "webSearchUrl": root.webSearchUrl,
            "terminal": root.terminal,
            "wallpaperDirectory": root.wallpaperDirectory,
            "currentThemeColors": root.currentThemeColors,
            "currentWallpaper": root.currentWallpaper,
            "wallpaperParallaxEnabled": root.wallpaperParallaxEnabled,
            "wallpaperParallaxStrength": root.wallpaperParallaxStrength,
            "workspaceStyle": root.workspaceStyle,
            "presets": root.presets
        };

        // Atomic write: Write to temp file then move to original
        // This prevents file corruption if the shell crashes during writing
        const jsonContent = JSON.stringify(data, null, 2);
        const tempFile = root.prefsFile + ".tmp";
        const cmd = `printf '%s' "$1" > "$2" && mv "$2" "$3"`;

        ProcessService.runDetached([
            "sh", "-c", cmd,
            "--",
            jsonContent,
            tempFile,
            root.prefsFile
        ]);
    }
    
    function savePreset(name) {
        if (!name || name.trim() === "") return;
        
        var newPresets = JSON.parse(JSON.stringify(root.presets));
        newPresets[name] = {
            "currentTheme": root.currentTheme,
            "shellFont": root.shellFont,
            "cornerRadius": root.cornerRadius,
            "desktopDim": root.desktopDim,
            "barPosition": root.barPosition,
            "barFitToContent": root.barFitToContent,
            "barDensity": root.barDensity,
            "barMarginTop": root.barMarginTop,
            "barMarginSide": root.barMarginSide,
            "notificationDensity": root.notificationDensity,
            "barLeftComponents": JSON.parse(JSON.stringify(root.barLeftComponents)),
            "barCenterComponents": JSON.parse(JSON.stringify(root.barCenterComponents)),
            "barRightComponents": JSON.parse(JSON.stringify(root.barRightComponents)),
            "blurEnabled": root.blurEnabled,
            "blurOpacity": root.blurOpacity,
            "blockOpacity": root.blockOpacity,
            "themedAppsOpacity": root.themedAppsOpacity
        };
        root.presets = newPresets;
        requestSave("savePreset");
    }

    function loadPreset(name) {
        var preset = root.presets[name];
        if (!preset) return;

        if (preset.hasOwnProperty("currentTheme")) {
            // Use ThemeService to apply theme properly
            ThemeService.setTheme(preset.currentTheme);
        }
        
        if (preset.hasOwnProperty("shellFont")) root.shellFont = preset.shellFont;
        if (preset.hasOwnProperty("cornerRadius")) root.cornerRadius = preset.cornerRadius;
        if (preset.hasOwnProperty("desktopDim")) root.desktopDim = preset.desktopDim;
        if (preset.hasOwnProperty("barPosition")) root.barPosition = preset.barPosition;
        if (preset.hasOwnProperty("barFitToContent")) root.barFitToContent = preset.barFitToContent;
        if (preset.hasOwnProperty("barDensity")) root.barDensity = preset.barDensity;
        if (preset.hasOwnProperty("barMarginTop")) root.barMarginTop = preset.barMarginTop;
        if (preset.hasOwnProperty("barMarginSide")) root.barMarginSide = preset.barMarginSide;
        if (preset.hasOwnProperty("notificationDensity")) root.notificationDensity = preset.notificationDensity;
        
        if (preset.hasOwnProperty("barLeftComponents")) root.barLeftComponents = preset.barLeftComponents;
        if (preset.hasOwnProperty("barCenterComponents")) root.barCenterComponents = preset.barCenterComponents;
        if (preset.hasOwnProperty("barRightComponents")) root.barRightComponents = preset.barRightComponents;
        if (preset.hasOwnProperty("blurEnabled")) root.blurEnabled = preset.blurEnabled;
        if (preset.hasOwnProperty("blurOpacity")) root.blurOpacity = preset.blurOpacity;
        if (preset.hasOwnProperty("blockOpacity")) root.blockOpacity = preset.blockOpacity;
        if (preset.hasOwnProperty("themedAppsOpacity")) root.themedAppsOpacity = preset.themedAppsOpacity;
        
        requestSave("loadPreset");
    }

    function deletePreset(name) {
        if (!root.presets[name]) return;
        
        var newPresets = JSON.parse(JSON.stringify(root.presets));
        delete newPresets[name];
        root.presets = newPresets;
        requestSave("deletePreset");
    }
    
    property Timer saveTimer: Timer {
        interval: 500
        repeat: false
        onTriggered: root.save()
    }

    function requestSave(reason) {
        if (loaded) {
            saveTimer.restart();
        }
    }

    onThemedAppsChanged: requestSave("themedApps")
    onNotificationModeChanged: requestSave("notificationMode")
    onDesktopDimChanged: requestSave("desktopDim")
    onWeatherLatChanged: requestSave("weatherLat")
    onWeatherLongChanged: requestSave("weatherLong")
    onWeatherLocationNameChanged: requestSave("weatherLocationName")
    onWeatherShowLocationChanged: requestSave("weatherShowLocation")
    onGowallEnabledChanged: requestSave("gowallEnabled")
    onBlurEnabledChanged: requestSave("blurEnabled")
    onBlurOpacityChanged: requestSave("blurOpacity")
    onBlockOpacityChanged: requestSave("blockOpacity")
    onThemedAppsOpacityChanged: requestSave("themedAppsOpacity")
    onCurrentThemeChanged: requestSave("currentTheme")
    onThemeModeChanged: requestSave("themeMode")
    onBarPositionChanged: requestSave("barPosition")
    onShellFontChanged: requestSave("shellFont")
    onBarDensityChanged: {
        if (barDensity === 0) root.barHeight = 50;
        else if (barDensity === 1) root.barHeight = 55;
        else if (barDensity === 2) root.barHeight = 60;
        requestSave("barDensity");
    }
    onNotificationDensityChanged: requestSave("notificationDensity")
    onWorkspaceStyleChanged: requestSave("workspaceStyle")

    onBarHeightChanged: requestSave("barHeight")
    onBarMarginTopChanged: requestSave("barMarginTop")
    onBarMarginSideChanged: requestSave("barMarginSide")
    onCornerRadiusChanged: requestSave("cornerRadius")
    onPopoutMarginChanged: requestSave("popoutMargin")
    onBarFitToContentChanged: requestSave("barFitToContent")
    onBarLeftComponentsChanged: requestSave("barLeftComponents")
    onBarCenterComponentsChanged: requestSave("barCenterComponents")
    onBarRightComponentsChanged: requestSave("barRightComponents")
    onWebSearchUrlChanged: requestSave("webSearchUrl")
    onTerminalChanged: requestSave("terminal")
    onWallpaperDirectoryChanged: requestSave("wallpaperDirectory")
    onCurrentThemeColorsChanged: requestSave("currentThemeColors")
    onCurrentWallpaperChanged: requestSave("currentWallpaper")
    onWallpaperParallaxEnabledChanged: requestSave("wallpaperParallaxEnabled")
    onWallpaperParallaxStrengthChanged: requestSave("wallpaperParallaxStrength")
    Component.onCompleted: {
        prefsFileView.reload();
    }

    safetyTimer: Timer {
        interval: 10000 
        running: true
        repeat: false
        onTriggered: {
            if (!root.loaded) {
                console.warn("[Preferences] Load timed out, assuming defaults. Manual changes will now be allowed.");
                root.loaded = true;
                // CRITICAL FIX: Do NOT automatically save here. 
                // Only allow the user to trigger a save by changing a setting.
            }
        }
    }

    prefsFileView: FileView {
        path: root.prefsFile
        watchChanges: false
        onLoadedChanged: {
            if (loaded) {
                const rawText = text();
                if (rawText.trim().length === 0) {
                    console.log("[Preferences] File is empty, skipping parse.");
                    safetyTimer.stop();
                    root.loaded = true;
                    return;
                }

                try {
                    var data = JSON.parse(rawText);
                    if (!data || typeof data !== "object") throw new Error("Invalid JSON");
                    if (data.hasOwnProperty("notificationMode"))
                        root.notificationMode = data.notificationMode;

                    if (data.hasOwnProperty("desktopDim"))
                        root.desktopDim = data.desktopDim;

                    if (data.hasOwnProperty("weatherLat"))
                        root.weatherLat = data.weatherLat;

                    if (data.hasOwnProperty("weatherLong"))
                        root.weatherLong = data.weatherLong;

                    if (data.hasOwnProperty("weatherLocationName"))
                        root.weatherLocationName = data.weatherLocationName;

                    if (data.hasOwnProperty("weatherShowLocation"))
                        root.weatherShowLocation = data.weatherShowLocation;

                    if (data.hasOwnProperty("gowallEnabled"))
                        root.gowallEnabled = data.gowallEnabled;

                    if (data.hasOwnProperty("blurEnabled"))
                        root.blurEnabled = data.blurEnabled;

                    if (data.hasOwnProperty("blurOpacity"))
                        root.blurOpacity = data.blurOpacity;

                    if (data.hasOwnProperty("blockOpacity"))
                        root.blockOpacity = data.blockOpacity;

                    if (data.hasOwnProperty("themedAppsOpacity"))
                        root.themedAppsOpacity = data.themedAppsOpacity;

                    if (data.hasOwnProperty("currentTheme"))
                        root.currentTheme = data.currentTheme;

                    if (data.hasOwnProperty("themeMode"))
                        root.themeMode = data.themeMode;

                    if (data.hasOwnProperty("barPosition"))
                        root.barPosition = data.barPosition;

                    if (data.hasOwnProperty("shellFont"))
                        root.shellFont = data.shellFont;

                    if (data.hasOwnProperty("barDensity"))
                        root.barDensity = data.barDensity;

                    if (data.hasOwnProperty("notificationDensity"))
                        root.notificationDensity = data.notificationDensity;


                    if (data.hasOwnProperty("barHeight"))
                        root.barHeight = data.barHeight;

                    if (data.hasOwnProperty("barMarginTop"))
                        root.barMarginTop = data.barMarginTop;

                    if (data.hasOwnProperty("barMarginSide"))
                        root.barMarginSide = data.barMarginSide;

                    if (data.hasOwnProperty("cornerRadius"))
                        root.cornerRadius = data.cornerRadius;

                    if (data.hasOwnProperty("popoutMargin"))
                        root.popoutMargin = data.popoutMargin;

                    if (data.hasOwnProperty("barFitToContent"))
                        root.barFitToContent = data.barFitToContent;


                    if (data.hasOwnProperty("barLeftComponents"))
                        root.barLeftComponents = data.barLeftComponents.map((c) => {
                        return c === "smartCapsule" ? "nowPlaying" : c;
                    }).filter((c) => {
                        return c !== "arch" && c !== "windowTitle" && c !== "network" && c !== "battery" && c !== "weather";
                    });

                    if (data.hasOwnProperty("barCenterComponents"))
                        root.barCenterComponents = data.barCenterComponents.map((c) => {
                        return c === "smartCapsule" ? "nowPlaying" : c;
                    }).filter((c) => {
                        return c !== "arch" && c !== "windowTitle" && c !== "network" && c !== "battery" && c !== "weather";
                    });

                    if (data.hasOwnProperty("barRightComponents"))
                        root.barRightComponents = data.barRightComponents.map((c) => {
                        return c === "smartCapsule" ? "nowPlaying" : c;
                    }).filter((c) => {
                        return c !== "arch" && c !== "windowTitle" && c !== "network" && c !== "battery" && c !== "weather";
                    });

                    if (data.hasOwnProperty("themedApps")) {
                        // Merge with defaults to ensure new app keys are present
                        let merged = JSON.parse(JSON.stringify(root.themedApps));
                        for (let k in data.themedApps) {
                            // Migration: gtk4 -> gtk
                            if (k === "gtk4") {
                                if (!data.themedApps.hasOwnProperty("gtk")) {
                                    merged["gtk"] = data.themedApps[k];
                                }
                                continue;
                            }
                            merged[k] = data.themedApps[k];
                        }
                        root.themedApps = merged;
                    }

                    if (data.hasOwnProperty("webSearchUrl"))
                        root.webSearchUrl = data.webSearchUrl;

                    if (data.hasOwnProperty("terminal"))
                        root.terminal = data.terminal;

                    if (data.hasOwnProperty("wallpaperDirectory"))
                        root.wallpaperDirectory = data.wallpaperDirectory;

                    if (data.hasOwnProperty("currentThemeColors"))
                        root.currentThemeColors = data.currentThemeColors;

                    if (data.hasOwnProperty("currentWallpaper"))
                        root.currentWallpaper = data.currentWallpaper;

                    if (data.hasOwnProperty("wallpaperParallaxEnabled"))
                        root.wallpaperParallaxEnabled = data.wallpaperParallaxEnabled;

                    if (data.hasOwnProperty("wallpaperParallaxStrength"))
                        root.wallpaperParallaxStrength = data.wallpaperParallaxStrength;

                    if (data.hasOwnProperty("workspaceStyle"))
                        root.workspaceStyle = data.workspaceStyle;
                    else if (data.hasOwnProperty("romanNumerals") && data.romanNumerals === true)
                        root.workspaceStyle = 1;

                    if (data.hasOwnProperty("presets"))
                        root.presets = data.presets;

                    safetyTimer.stop();
                    root.loaded = true;
                } catch (e) {
                    console.error("[Preferences] Failed to parse preferences file:", e.message);
                }
            }
        }
    }

}
