import QtQuick
import Quickshell
pragma Singleton

QtObject {
    //==========================================================================
    // UPDATE INTERVALS & TIMEOUTS
    //==========================================================================
    readonly property int statsUpdateInterval: 2000
    readonly property int notificationTimeout: 5000 // 5 seconds
    readonly property int notificationToastStackMarginTop: 70
    readonly property int notificationToastMarginRight: 10

    //==========================================================================
    // PATHS & EXTERNAL RESOURCES
    //==========================================================================
    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string rootDir: homeDir + "/.config/quickshell"
    readonly property string assetsDir: rootDir + "/assets"
    readonly property string scriptsDir: rootDir + "/scripts"
    readonly property string themesDir: assetsDir + "/themes"
    readonly property string cacheDir: homeDir + "/.cache/quickshell"
    
    readonly property string terminal: "kitty"
    readonly property string webSearchUrl: "https://duckduckgo.com/?q="
    readonly property string notificationSoundPath: assetsDir + "/ping.mp3"
    readonly property bool notificationSoundEnabled: true
    readonly property int notificationSoundVolume: 35

    //==========================================================================
    // LIMITS & CONSTRAINTS
    //==========================================================================
    readonly property int launcherMaxResults: 100

    //==========================================================================
    // PERSISTENCE & CACHE FILES
    //==========================================================================
    readonly property string frequencyFile: cacheDir + "/launcher.json"
    readonly property string wallpaperListFile: cacheDir + "/wallpaper.json"
    
    // Legacy mapping (for compatibility during transition if needed)
    readonly property string prefsFile: cacheDir + "/preferences.json"
}
