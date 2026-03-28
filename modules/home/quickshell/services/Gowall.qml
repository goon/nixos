import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services
pragma Singleton

/**
 * Gowall Service
 * 
 * Manages the integration with 'gowall' to themify wallpapers.
 * - Updates ~/.config/gowall/config.yml with the current system theme.
 * - Converts the current wallpaper using the active theme.
 */
QtObject {
    id: root

    // --- State ---
    property bool processing: false
    property string lastProcessedWallpaper: "" // To avoid reprocessing loops

    // --- Dependencies ---
    property bool enabled: Preferences.gowallEnabled
    property var currentColors: ThemeService.currentColors
    property string currentThemeId: Preferences.currentTheme
    property string currentWallpaper: Wallpaper.currentWallpaper
    
    // --- Paths ---
    readonly property string gowallConfigDir: Config.homeDir + "/.config/gowall"
    readonly property string gowallConfigFile: gowallConfigDir + "/config.yml"
    readonly property string cacheDir: Config.cacheDir + "/wallpapers"

    // --- Components ---

    // 1. Config Writer Process (Local, no StdioCollector needed)
    property Process configWriter: Process {
        id: configWriter
        command: [] 
        onExited: (exitCode) => {
             if (exitCode === 0) {
                 convertTimer.restart(); 
             } else {
                 root.processing = false;
             }
        }
    }


    
    property string lastTarget: ""
    
    // ...

    function writeGowallConfig() {
        if (!currentColors) {
            processing = false;
            return;
        }

        var c = currentColors;
        var colorList = [
            c.background, c.surface, c.surfaceAlt, 
            c.primary, c.secondary, c.accent,
            c.text, c.textDim, c.muted,
            c.success, c.warning, c.error
        ];
        
        colorList = colorList.filter(c => c && c.startsWith("#"));

        var yaml = "themes:\n  - name: \"" + currentThemeId + "\"\n    colors:\n";
        for (var i = 0; i < colorList.length; i++) {
            yaml += "      - \"" + colorList[i] + "\"\n";
        }


        
        // Write using sh
        configWriter.command = ["sh", "-c", "printf '%s' \"$1\" > \"$2\"", "--", yaml, gowallConfigFile];
        configWriter.running = true;
    }
    
    property Timer convertTimer: Timer {
        interval: 100
        repeat: false
        onTriggered: root.convertWallpaper()
    }

    function convertWallpaper() {
        // Unique filename per theme to force QML to reload the image
        var ext = currentWallpaper.split(".").pop();
        var baseName = currentWallpaper.split("/").pop().split(".").shift();
        var fileName = baseName + "_" + currentThemeId + "." + ext;
        
        var targetPath = cacheDir + "/" + fileName;
        root.lastTarget = targetPath;
    
        // Strategy: Detached Execution via Helper Script
        // We runs scripts/gowall.sh in the background to avoid blocking the UI.
        // The script uses Unix pipes to safely stream data to/from gowall.
        var realScriptPath = Config.scriptsDir + "/gowall.sh"; 
        
        // Construct the detached command
        // Args: input_file, theme_id, output_path
        var cmd = "nohup \"" + realScriptPath + "\" \"" + currentWallpaper + "\" \"" + currentThemeId + "\" \"" + targetPath + "\" > /dev/null 2>&1 &";
        
        launcher.command = ["sh", "-c", cmd];
        launcher.running = true;
        
        // Start Polling
        root.pollAttempts = 0;
        root.targetPollFile = targetPath;
        pollingTimer.restart();
    }
    
    // Launcher Process - Pure fire and forget, no listeners
    property Process launcher: Process {
        id: launcher
        stdout: null
        stderr: null
        onExited: (code) => { /* Launcher finished */ }
    }

    property int pollAttempts: 0
    property int maxPollAttempts: 60 
    property string targetPollFile: ""
    
    // Polling Timer
    property Timer pollingTimer: Timer {
        interval: 500
        repeat: true
        running: false
        onTriggered: {
            root.pollAttempts++;
            if (root.pollAttempts > root.maxPollAttempts) {
                stop();
                root.processing = false;
                return;
            }
            
            checkFileProcess.command = ["test", "-f", root.targetPollFile];
            checkFileProcess.running = true;
        }
    }
    
    property Process checkFileProcess: Process {
        id: checkFileProcess
        command: []
        onExited: (exitCode) => {
            if (exitCode === 0) {
                // File detected
                root.pollingTimer.stop();
                root.processing = false;
                Wallpaper.processedWallpaper = root.targetPollFile;
            } 
        }
    }

    // --- Logic ---
    property bool initialized: true 

    // Watch for changes
    onEnabledChanged: update()
    onCurrentThemeIdChanged: update()
    onCurrentWallpaperChanged: update()

    function update() {
        if (!enabled) {
            Wallpaper.processedWallpaper = "";
            return;
        }

        // If we are already displaying the correct processed file for this theme/wallpaper combination, do nothing.
        // We reconstruct the expected filename to check this.
        var ext = currentWallpaper.split(".").pop();
        var baseName = currentWallpaper.split("/").pop().split(".").shift();
        var expectedFileName = baseName + "_" + currentThemeId + "." + ext;
        var expectedPath = cacheDir + "/" + expectedFileName;

        if (currentWallpaper === "" || Wallpaper.processedWallpaper === expectedPath) {
             return;
        }
        
        process();
    }

    function process() {
        if (processing) return; 
        processing = true;

        // Ensure directories (Fast, fire and forget)
        ProcessService.runDetached(["mkdir", "-p", gowallConfigDir]);
        ProcessService.runDetached(["mkdir", "-p", cacheDir]);

        // Write Config
        writeGowallConfig();
    }


}
