import QtQuick
import Quickshell
import Quickshell.Io
import qs
pragma Singleton

/**
 * Wallpaper Service
 * 
 * Handles wallpaper selection and persistence.
 */
Item {
    id: root

    // --- State Properties ---
    property var wallpapers: []
    property string currentWallpaper: ""
    property int wallpaperVersion: 0 
    
    // UI State
    property bool isLoading: false
    property bool hasScanned: false
    
    // --- Computed Source ---
    // This is the SINGLE source of truth for the UI.
    property string processedWallpaper: ""
    property string displayWallpaper: (Preferences.gowallEnabled && processedWallpaper !== "") ? processedWallpaper : currentWallpaper

    // --- Child Components ---
    FileView {
        id: listCacheView
        path: Config.wallpaperListFile
        onLoadedChanged: {
            if (loaded && !root.hasScanned) {
                try {
                    var json = JSON.parse(text());
                    if (Array.isArray(json)) root.wallpapers = json;
                } catch (e) {}
            }
        }
    }

    Connections {
        target: Preferences
        function onLoadedChanged() {
            if (Preferences.loaded) {
                if (root.currentWallpaper === "") {
                    root.currentWallpaper = Preferences.currentWallpaper;
                }
                if (!root.hasScanned) {
                    root.scanWallpapers();
                }
            }
        }
        function onWallpaperDirectoryChanged() {
            if (Preferences.loaded) {
                root.refreshWallpapers();
            }
        }
    }

    // --- Signals ---
    signal wallpapersScanned()
    signal wallpaperSet(string path)

    // --- Public API ---

    /**
     * Updates the current wallpaper. 
     */
    function setWallpaper(path) {
        if (!path || path === "" || root.currentWallpaper === path) return;

        root.currentWallpaper = path;
        
        // 1. Persist selection immediately via Preferences service
        Preferences.currentWallpaper = path;
        
        // 2. Notify system
        root.wallpaperSet(path);
        ProcessService.runDetached(["notify-send", "-a", "Wallpaper", "-i", "symbol:image", "Wallpaper", "The <b>" + path.split("/").pop() + "</b> wallpaper has been applied."]);
    }

    function applyWallpaper(path) { setWallpaper(path); }
    function ensureScanned() { 
        if (!hasScanned) {
            if (Preferences.loaded) {
                scanWallpapers(); 
            } else {
                console.log("[WallpaperService] ensureScanned called before Preferences loaded, skipping until load");
            }
        }
    }
    function refreshWallpapers() { hasScanned = false; scanWallpapers(); }
    
    function setRandomWallpaper() {
        ensureScanned();
        if (wallpapers.length > 0) {
            setWallpaper(wallpapers[Math.floor(Math.random() * wallpapers.length)]);
        }
    }

    function shuffleWallpapers() {
        if (!wallpapers || wallpapers.length <= 1) return;
        
        var shuffled = [...wallpapers];
        for (var i = shuffled.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
        }
        wallpapers = shuffled;
    }

    // --- Internal Logic ---

    property Timer scanRetryTimer: Timer {
        interval: 1000
        repeat: false
        onTriggered: root.scanWallpapers()
    }

    // Expand $HOME and ~ in a path string to the actual home directory
    function expandPath(path) {
        var home = Config.homeDir;
        if (path.indexOf("$HOME") === 0) return home + path.substring(5);
        if (path.indexOf("~") === 0) return home + path.substring(1);
        return path;
    }

    function scanWallpapers() {
        if (isLoading) return; 
        
        // Expand $HOME and ~ in the directory path
        var dir = expandPath(Preferences.wallpaperDirectory);
        if (!dir || dir === "" || dir === "/home/michael/Pictures/wall") { // Handle truncated path if present
             dir = expandPath("~/Pictures/wallpapers");
        }

        if (!dir || dir === "") {
            console.warn("[WallpaperService] No valid directory to scan");
            root.wallpapers = [];
            root.hasScanned = true;
            return;
        }
        
        // Use multiple -iname arguments for better portability and robustness
        var cmd = ["find", dir, "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", ")"];
        
        var proc = ProcessService.run(cmd, function(output) {
            var list = output.trim().split("\n").filter(l => l.length > 0);
            
            root.wallpapers = list;
            root.isLoading = false;
            root.hasScanned = true;
            
            // Provide variety from the start
            root.shuffleWallpapers();
            
            // Sync list cache
            ProcessService.runDetached(["sh", "-c", "printf '%s' \"$1\" > \"$2\"", "--", JSON.stringify(list), Config.wallpaperListFile]);
            
            if (root.currentWallpaper === "" && list.length > 0) {
                setWallpaper(list[Math.floor(Math.random() * list.length)]);
            }
        });

        if (proc) {
            isLoading = true;
        } else {
            scanRetryTimer.start();
        }
    }

    Component.onCompleted: {
        if (Preferences.loaded) {
            scanWallpapers();
        } 
    }
}