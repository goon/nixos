import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services
pragma Singleton

Item {
    id: root

    property bool ready: false
    property var currentColors: ({})
    property var allThemes: []
    readonly property alias availableStockThemes: root.allThemes
    readonly property string themesDir: Config.themesDir
    readonly property string scriptsDir: Config.scriptsDir
    property var stockThemeIds: ["catppuccin", "kanagawa", "everforest", "gruvbox", "horizon", "solaris"]

    // --- State Properties (System Theme) ---
    property string gtkTheme: ""
    property string iconTheme: ""
    property string fontName: ""
    property string colorScheme: "" // prefer-dark, prefer-light, default
    property var availableGtkThemes: []
    property var availableIconThemes: []
    property string cursorTheme: ""
    property int cursorSize: 24
    property var availableCursorThemes: []

    property var hookFiles: []
    property var installedApps: ({})
    property var scanningHooks: false
    readonly property int debounceInterval: 300

    function registerTheme(id, jsonText) {
        try {
            const json = JSON.parse(jsonText);
            var entry = {
                "id": id,
                "name": json.name || id,
                "colors": json
            };
            var newThemes = root.allThemes;
            // Check if already exists to prevent duplicates
            var existingIdx = -1;
            for (var i = 0; i < newThemes.length; i++) {
                if (newThemes[i].id === id) {
                    existingIdx = i;
                    break;
                }
            }
            if (existingIdx !== -1)
                newThemes[existingIdx] = entry;
            else
                newThemes.push(entry);
            // Re-signal the property
            root.allThemes = [];
            root.allThemes = newThemes;
            // If this is the current theme, ensure UI is up to date
            if (id === Preferences.currentTheme)
                root.applyThemeColors(json);

        } catch (e) {
        }
    }

    function setTheme(id) {
        Preferences.currentTheme = id;
        var themeData = null;
        for (var i = 0; i < allThemes.length; i++) {
            if (allThemes[i].id === id) {
                themeData = allThemes[i].colors;
                break;
            }
        }
        if (themeData) {
            root.applyThemeColors(themeData);
            Preferences.currentThemeColors = themeData;
            root.triggerHooks(id, themesDir + "/" + id);
            ProcessService.runDetached(["notify-send", "-a", "Theme", "-i", "symbol:palette", "Theme", "The <b>" + id.charAt(0).toUpperCase() + id.slice(1) + "</b> theme has been applied."]);
        }
    }

    function applyThemeColors(data) {
        if (!data)
            return;
        root.currentColors = data;
        root.ready = true;
    }

    function loadDefaultFallback() {
        currentColors = {
            "background": "#1a1a24",
            "surface": "#23232d",
            "surfaceAlt": "#2a2a37",
            "primary": "#d4a76a",
            "text": "#e0e0e6",
            "textDim": "#6a6a7a"
        };
        ready = true;
    }

    function refreshThemeService() {
        // GTK Theme
        ProcessService.run(["gsettings", "get", "org.gnome.desktop.interface", "gtk-theme"], function(out) {
            root.gtkTheme = out.trim().replace(/'/g, "");
        });
        // Icon Theme
        ProcessService.run(["gsettings", "get", "org.gnome.desktop.interface", "icon-theme"], function(out) {
            root.iconTheme = out.trim().replace(/'/g, "");
        });
        // Cursor Theme
        ProcessService.run(["gsettings", "get", "org.gnome.desktop.interface", "cursor-theme"], function(out) {
            root.cursorTheme = out.trim().replace(/'/g, "");
        });
        // Cursor Size
        ProcessService.run(["gsettings", "get", "org.gnome.desktop.interface", "cursor-size"], function(out) {
            var val = parseInt(out.trim());
            root.cursorSize = isNaN(val) ? 24 : val;
        });
        // Font Name
        ProcessService.run(["gsettings", "get", "org.gnome.desktop.interface", "font-name"], function(out) {
            root.fontName = out.trim().replace(/'/g, "");
        });
        // Color Scheme
        ProcessService.run(["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"], function(out) {
            root.colorScheme = out.trim().replace(/'/g, "");
        });
    }

    function scanThemeServices() {
        // POSIX-compliant discovery using XDG_DATA_DIRS and following symlinks (-L)
        const agnosticCmd = `
            echo "$XDG_DATA_DIRS:/usr/local/share:/usr/share" | tr ':' '\\n' | while read -r dir; do
                [ -d "$dir/themes" ] && find -L "$dir/themes" -mindepth 1 -maxdepth 1 -type d -printf '%f\\n' 2>/dev/null
                [ "$dir" = "$HOME/.themes" ] && find -L "$dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\\n' 2>/dev/null
            done | sort | uniq
        `;

        ProcessService.run(["sh", "-c", agnosticCmd], function(out) {
            var lines = out.split('\n').filter(function(l) {
                return l.length > 0 && l !== "themes" && l !== ".themes" && l[0] !== '.';
            });
            root.availableGtkThemes = lines;
        });

        // Icon Themes (Exclude cursors)
        const agnosticIconsCmd = `
            echo "$XDG_DATA_DIRS:/usr/local/share:/usr/share" | tr ':' '\\n' | while read -r dir; do
                SDIR="$dir"
                [ -d "$dir/icons" ] && SDIR="$dir/icons"
                [ -d "$SDIR" ] && for d in "$SDIR"/*; do
                    [ -d "$d" ] && [ -f "$d/index.theme" ] && [ ! -d "$d/cursors" ] && [ ! -f "$d/cursor.theme" ] && basename "$d"
                done
            done 2>/dev/null | sort | uniq
        `;

        ProcessService.run(["sh", "-c", agnosticIconsCmd], function(out) {
            var lines = out.split('\n').filter(function(l) {
                return l.length > 0 && l !== "icons" && l !== ".icons" && l[0] !== '.';
            });
            root.availableIconThemes = lines;
        });

        // Cursors
        scanCursorThemes();
    }

    function scanCursorThemes() {
        const agnosticCursorsCmd = `
            echo "$XDG_DATA_DIRS:/usr/local/share:/usr/share" | tr ':' '\\n' | while read -r dir; do
                SDIR="$dir"
                [ -d "$dir/icons" ] && SDIR="$dir/icons"
                [ -d "$SDIR" ] && for d in "$SDIR"/*; do
                    [ -d "$d" ] && { [ -d "$d/cursors" ] || [ -f "$d/cursor.theme" ]; } && basename "$d"
                done
            done 2>/dev/null | sort | uniq
        `;

        ProcessService.run(["sh", "-c", agnosticCursorsCmd], function(out) {
            var lines = out.split('\n').filter(function(l) {
                return l.length > 0;
            });
            root.availableCursorThemes = lines;
        });
    }

    function updateGtkConfig(key, value) {
        var gtk3File = "~/.config/gtk-3.0/settings.ini";
        var gtk4File = "~/.config/gtk-4.0/settings.ini";
        var cmd3 = ["sh", "-c", "sed -i 's|^" + key + "=.*|" + key + "=" + value + "|' " + gtk3File];
        ProcessService.runDetached(cmd3);
        var cmd4 = ["sh", "-c", "sed -i 's|^" + key + "=.*|" + key + "=" + value + "|' " + gtk4File];
        ProcessService.runDetached(cmd4);
    }

    function updateGtk2Config(key, value) {
        var gtk2File = "~/.gtkrc-2.0";
        var cmd = ["sh", "-c", "sed -i 's|^" + key + " =.*|" + key + " = \"" + value + "\";|' " + gtk2File];
        ProcessService.runDetached(cmd);
        var robustCmd = ["sh", "-c", "sed -i 's|^" + key + "\\s*=\\s*.*|" + key + " = \"" + value + "\";|' " + gtk2File];
        ProcessService.runDetached(robustCmd);
    }

    function setGtkTheme(name) {
        ProcessService.run(["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", "'" + name + "'"], function() {
            refreshThemeService();
        });
        updateGtkConfig("gtk-theme-name", name);
        updateGtk2Config("gtk-theme-name", name);
    }

    function setIconTheme(name) {
        ProcessService.run(["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", "'" + name + "'"], function() {
            refreshThemeService();
        });
        updateGtkConfig("gtk-icon-theme-name", name);
        updateGtk2Config("gtk-icon-theme-name", name);
    }

    function setCursorTheme(name) {
        ProcessService.run(["gsettings", "set", "org.gnome.desktop.interface", "cursor-theme", "'" + name + "'"], function() {
            refreshThemeService();
        });
        updateGtkConfig("gtk-cursor-theme-name", name);
        updateGtk2Config("gtk-cursor-theme-name", name);
    }

    function setCursorSize(size) {
        ProcessService.run(["gsettings", "set", "org.gnome.desktop.interface", "cursor-size", size.toString()], function() {
            refreshThemeService();
        });
        updateGtkConfig("gtk-cursor-theme-size", size);
        updateGtk2Config("gtk-cursor-theme-size", size);
    }

    function setFontName(name) {
        ProcessService.run(["gsettings", "set", "org.gnome.desktop.interface", "font-name", "'" + name + "'"], function() {
            refreshThemeService();
        });
        updateGtkConfig("gtk-font-name", name);
        updateGtk2Config("gtk-font-name", name);
    }

    function setFontSize(size) {
        var current = root.fontName;
        var match = current.match(/(.*)\s+(\d+)$/);
        if (match) {
            var family = match[1];
            var newFontName = family + " " + size;
            setFontName(newFontName);
        } else {
            setFontName(current + " " + size);
        }
    }

    function toggleColorScheme() {
        var newScheme = (root.colorScheme === 'prefer-dark') ? 'default' : 'prefer-dark';
        ProcessService.run(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", newScheme], function() {
            refreshThemeService();
        });
    }

    function findIndexCaseInsensitive(list, value) {
        if (!list || !value) return -1;
        var lowerValue = value.toLowerCase();
        for (var i = 0; i < list.length; i++) {
            if (list[i].toLowerCase() === lowerValue) {
                return i;
            }
        }
        return -1;
    }

    property var allFontFamilies: []
    function updateFontFamilies() {
        const families = Qt.fontFamilies();
        const blacklist = /(mtx|math|private|opensymbol|stix|tex|pfont|noto sans .* [0-9])/i;
        root.allFontFamilies = families.filter((font) => {
            return !blacklist.test(font);
        });
    }

    function getCleanFontFamilies() {
        if (allFontFamilies.length === 0) updateFontFamilies();
        return allFontFamilies;
    }

    // -------------------------------------------------------------------------
    // --- Hook Service Logic
    // -------------------------------------------------------------------------

    function scanHooks() {
        if (root.scanningHooks) return;
        root.scanningHooks = true;
        
        var base = root.scriptsDir + "/";
        var files = [];
        
        for (var i = 0; i < ThemeRegistration.applications.length; i++) {
            files.push(base + ThemeRegistration.applications[i].script);
        }
        
        root.hookFiles = files;
        root.scanningHooks = false;
        root.checkInstalledApps();
    }

    function checkInstalledApps() {
        let newInstalled = {};
        let apps = ThemeRegistration.applications;
        let completed = 0;

        apps.forEach(app => {
            ProcessService.run(["sh", "-c", app.binary + " > /dev/null 2>&1"], function(out, exitCode) {
                newInstalled[app.id] = (exitCode === 0);
                completed++;
                if (completed === apps.length) {
                    root.installedApps = newInstalled;
                }
            });
        });
    }

    function triggerHooks(themeId, themePath, context = "manual") {
        root.scanHooks(); // Re-scan to catch newly added/chmodded scripts
        executionTimer.pendingId = themeId;
        executionTimer.pendingPath = themePath;
        executionTimer.pendingContext = context;
        executionTimer.restart();
    }

    function executeHooks(id, path, context = "manual") {
        if (!hookFiles || hookFiles.length === 0) return;
        
        if (!Preferences.loaded) {
            console.warn("[ThemeService] Attempted to execute hooks before Preferences were loaded. Skipping.");
            return;
        }

        let commandString = "";
        let executedApps = [];
        
        for (let i = 0; i < ThemeRegistration.applications.length; i++) {
            let app = ThemeRegistration.applications[i];
            let hookFile = root.scriptsDir + "/" + app.script;
            
            if (Preferences.themedApps[app.id] !== true) {
                continue;
            }
            
            executedApps.push(app.id);
            commandString += `sh "${hookFile}" "${id}" "${path}" "${context}" "${Preferences.themedAppsOpacity}" "${Preferences.themeMode}"; `;
        }
        
        if (commandString === "") return;

        let safeCmd = commandString.replace(/'/g, "'\\''");
        ProcessService.runDetached(["sh", "-c", safeCmd]);
    }


    // Helper to run startup hooks exactly once when both cache and prefs are ready
    property bool _startupHooksRun: false
    function runStartupHooks() {
        if (_startupHooksRun || !Preferences.loaded) return;
        
        if (Preferences.currentThemeColors && Object.keys(Preferences.currentThemeColors).length > 0) {
            root.applyThemeColors(Preferences.currentThemeColors);
        } else {
            root.loadDefaultFallback();
        }

        if (Preferences.currentTheme) {
            _startupHooksRun = true;
            root.triggerHooks(Preferences.currentTheme, root.themesDir + "/" + Preferences.currentTheme, "startup");
        }
    }

    property Timer executionTimer: Timer {
        id: executionTimer
        interval: root.debounceInterval
        repeat: false
        
        property string pendingId: ""
        property string pendingPath: ""
        property string pendingContext: "manual"

        onTriggered: {
            root.executeHooks(pendingId, pendingPath, pendingContext);
        }
    }

    // -------------------------------------------------------------------------
    // --- Components
    // -------------------------------------------------------------------------
    
    Instantiator {
        model: root.stockThemeIds

        delegate: FileView {
            path: root.themesDir + "/" + modelData + "/colors.json"
            onLoadedChanged: {
                if (loaded)
                    root.registerTheme(modelData, text());
            }
        }
    }

    Connections {
        target: Preferences
        function onLoadedChanged() {
            if (Preferences.loaded) {
                root.runStartupHooks();
            }
        }

        function onThemedAppsOpacityChanged() {
            if (Preferences.loaded) {
                root.triggerHooks(Preferences.currentTheme, root.themesDir + "/" + Preferences.currentTheme, "opacity_update");
            }
        }
    }

    Component.onCompleted: {
        refreshThemeService();
        scanThemeServices();
        scanHooks();
        updateFontFamilies();
    }
}
