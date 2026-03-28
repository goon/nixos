import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import qs
pragma Singleton

QtObject {
    id: root

    // Input State Management
    property string lastInputMethod: "keyboard"
    property point originMousePos: Qt.point(-1, -1)
    property bool mouseSelectionEnabled: false
    property point lastMousePos: Qt.point(-1, -1)
    readonly property int moveThreshold: 10
    // Frequency tracking
    property var launchCounts: ({
    })
    readonly property string frequencyFile: Config.frequencyFile
    readonly property int maxFrequencyEntries: 100
    property FileView fregFileView

    function resetInputStates() {
        lastInputMethod = "keyboard";
        mouseSelectionEnabled = false;
        originMousePos = Qt.point(-1, -1);
        lastMousePos = Qt.point(-1, -1);
    }

    function handleMouseMove(globalX, globalY) {
        if (originMousePos.x === -1) {
            originMousePos = Qt.point(globalX, globalY);
            lastMousePos = Qt.point(globalX, globalY);
            return false;
        }
        var dx = Math.abs(globalX - lastMousePos.x);
        var dy = Math.abs(globalY - lastMousePos.y);
        // If movement is significant, enable mouse selection
        if (dx > 2 || dy > 2) {
            lastMousePos = Qt.point(globalX, globalY);
            if (!mouseSelectionEnabled) {
                var totalDx = Math.abs(globalX - originMousePos.x);
                var totalDy = Math.abs(globalY - originMousePos.y);
                if (totalDx > moveThreshold || totalDy > moveThreshold) {
                    mouseSelectionEnabled = true;
                    lastInputMethod = "mouse";
                }
            } else {
                lastInputMethod = "mouse";
            }
        }
        return mouseSelectionEnabled && lastInputMethod === "mouse";
    }

    function fuzzyMatch(text, query) {
        if (!query)
            return true;

        text = text.toLowerCase();
        query = query.toLowerCase();
        var idx = 0;
        for (var i = 0; i < text.length && idx < query.length; i++) {
            if (text[i] === query[idx])
                idx++;

        }
        return idx === query.length;
    }

    function saveFrequencyData() {
        var entries = [];
        for (var key in launchCounts) {
            if (launchCounts.hasOwnProperty(key))
                entries.push({
                "name": key,
                "count": launchCounts[key]
            });

        }
        if (entries.length > maxFrequencyEntries) {
            entries.sort((a, b) => {
                return b.count - a.count;
            });
            var trimmed = {
            };
            for (var i = 0; i < maxFrequencyEntries; i++) {
                trimmed[entries[i].name] = entries[i].count;
            }
            launchCounts = trimmed;
        }
        var json = JSON.stringify(launchCounts);
        root.fregFileView.setText(json);
    }

    function incrementAppFrequency(appName) {
        launchCounts[appName] = (launchCounts[appName] || 0) + 1;
        saveFrequencyData();
    }

    function getIconFromDesktop(appId) {
        if (!appId) return "";
        var apps = DesktopEntries.applications.values;
        var lowerId = appId.toLowerCase();
        
        for (var i = 0; i < apps.length; i++) {
            var app = apps[i];
            var entryId = (app.id || "").toLowerCase();
            
            if (entryId === lowerId || entryId === lowerId + ".desktop" || 
                (app.name && app.name.toLowerCase() === lowerId) ||
                (app.startupClass && app.startupClass.toLowerCase() === lowerId)) {
                return app.icon;
            }
        }
        return "";
    }

    function resolveIcon(iconName) {
        function getVerifiedPath(name) {
            if (!name)
                return "";

            var path = Quickshell.iconPath(name, true);
            if (!path)
                return "";

            var s = path.toString();
            if (s === "" || s.indexOf("image-missing") !== -1 || s.indexOf("missing") !== -1)
                return "";

            if (s.startsWith("image://") || s.startsWith("file://"))
                return s;

            if (s.startsWith("/"))
                return "file://" + s;

            return s;
        }

        if (!iconName)
            return "";

        // Symbols are handled internally by UI components (e.g. NotificationCard)
        // Returning empty here prevents Quickshell from trying to load them as themed icons
        if (iconName.startsWith("symbol:") || iconName.includes("symbol:"))
            return "";

        if (iconName.startsWith("/") || iconName.startsWith("file://") || iconName.startsWith("image://")) {
            if (iconName.startsWith("/"))
                return "file://" + iconName;

            return iconName;
        }

        // --- Proper Fix: Lookup in Desktop Entries first ---
        var desktopIcon = getIconFromDesktop(iconName);
        if (desktopIcon) {
            var dp = getVerifiedPath(desktopIcon);
            if (dp) return dp;
        }

        var v = getVerifiedPath(iconName);
        if (v)
            return v;

        var variations = [];
        var lowerIcon = iconName.toLowerCase();
        
        variations.push(iconName);
        variations.push(lowerIcon);

        if (iconName.length > 0) {
            var firstChar = iconName.charAt(0);
            var rest = iconName.slice(1);
            if (firstChar === firstChar.toUpperCase())
                variations.push(firstChar.toLowerCase() + rest);
            else
                variations.push(firstChar.toUpperCase() + rest);
        }
        
        // Use symbolic/panel variants ONLY as fallbacks
        variations.push(lowerIcon + "-symbolic");
        variations.push(iconName + "-symbolic");
        variations.push(lowerIcon + "-indicator");
        variations.push(iconName + "-indicator");
        variations.push(lowerIcon + "-panel");
        variations.push(iconName + "-panel");

        if (iconName.indexOf('.') !== -1)
            variations.push(iconName.split('.').pop());

        for (var i = 0; i < variations.length; i++) {
            if (variations[i] === iconName && i > 0)
                continue;

            var hv = getVerifiedPath(variations[i]);
            if (hv)
                return hv;
        }
        return "";
    }

    function searchApps(query, applications, workspaces, maxResults) {
        maxResults = maxResults || 100;
        var queryLower = query.toLowerCase();
        // --- Web Search Mode ---
        if (queryLower.startsWith("!s ") || queryLower.startsWith("!y ")) {
            var bangPrefix = queryLower.split(" ")[0];
            var webQuery = query.substring(bangPrefix.length + 1);
            if (webQuery.length > 0) {
                var searchUrl = Preferences.webSearchUrl;
                var searchName = "Search Web";
                if (bangPrefix === "!y") {
                    searchUrl = "https://www.youtube.com/results?search_query=";
                    searchName = "Search YouTube";
                }
                return [{
                    "type": "web",
                    "name": searchName + " for '" + webQuery + "'",
                    "description": "Open search in browser",
                    "icon": "web-browser",
                    "url": searchUrl + encodeURIComponent(webQuery)
                }];
            }
        }
        var scored = [];
        // --- 3. Applications ---
        for (var i = 0; i < applications.length; i++) {
            var app = applications[i];
            if (app.noDisplay)
                continue;

            var name = (app.name || "").toLowerCase();
            var comment = (app.comment || "").toLowerCase();
            var genericName = (app.genericName || "").toLowerCase();
            if (queryLower === "" || fuzzyMatch(name, queryLower) || fuzzyMatch(comment, queryLower) || fuzzyMatch(genericName, queryLower)) {
                var score = 0;
                var frequency = launchCounts[app.name] || 0;
                score += frequency * 50;
                if (queryLower !== "") {
                    if (name === queryLower)
                        score += 2000;
                    else if (name.startsWith(queryLower))
                        score += 1000;
                    else if (name.includes(queryLower))
                        score += 500;
                    else
                        score += 100;
                } else {
                    score += frequency > 0 ? 50 : 0; // Show frequent apps first
                }
                scored.push({
                    "item": {
                        "type": "app",
                        "name": app.name,
                        "description": app.comment || app.genericName || "Application",
                        "icon": app.icon,
                        "category": "Application",
                        "app": app
                    },
                    "score": score
                });
            }
        }
        scored.sort((a, b) => {
            return b.score - a.score;
        });
        var finalResults = [];
        for (var i = 0; i < Math.min(scored.length, maxResults); i++) {
            finalResults.push(scored[i].item);
        }
        return finalResults;
    }

    function evaluateCalculator(expr) {
        expr = expr.trim();
        if (expr.startsWith("=")) {
            expr = expr.substring(1).trim();
        }

        var pos = 0;
        function peek(str) {
            return expr.substring(pos, pos + str.length) === str;
        }

        function consume(str) {
            if (peek(str)) {
                pos += str.length;
                return true;
            }
            return false;
        }

        function parseExpression() {
            var x = parseTerm();
            while (true)if (consume('+'))
                x += parseTerm();
            else if (consume('-'))
                x -= parseTerm();
            else
                return x;
        }

        function parseTerm() {
            var x = parseFactor();
            while (true)if (consume('*'))
                x *= parseFactor();
            else if (consume('/'))
                x /= parseFactor();
            else
                return x;
        }

        function parseFactor() {
            if (consume('+'))
                return parseFactor();

            if (consume('-'))
                return -parseFactor();

            var x;
            var startPos = pos;
            if (consume('(')) {
                x = parseExpression();
                consume(')');
            } else if (peek('sqrt(')) {
                consume('sqrt(');
                x = Math.sqrt(parseExpression());
                consume(')');
            } else if (peek('pow(')) {
                consume('pow(');
                var base = parseExpression();
                consume(',');
                var exp = parseExpression();
                x = Math.pow(base, exp);
                consume(')');
            } else {
                while (pos < expr.length && /[0-9.]/.test(expr[pos]))pos++
                x = parseFloat(expr.substring(startPos, pos));
            }
            return x;
        }

        expr = expr.replace(/\s/g, '');
        if (!/^[0-9+\-*\/().a-z0-9,]+$/.test(expr))
            return null;

        try {
            var result = parseExpression();
            if (pos !== expr.length)
                return null;

            if (typeof result === 'number' && !isNaN(result) && isFinite(result))
                return result;

        } catch (e) {
        }
        return null;
    }

    function isCommandMode(query) {
        return query.startsWith(">");
    }

    function getCommandText(query) {
        return query.substring(1);
    }


    function runCommand(command, inTerminal) {
        if (!command)
            return ;

        if (inTerminal)
            ProcessService.runDetached([Preferences.terminal, "-e", "sh", "-c", command + "; read"]);
        else
            ProcessService.runDetached(["sh", "-c", command]);
    }

    function executeItem(item) {
        if (!item)
            return ;

        if (item.type === "app") {
            incrementAppFrequency(item.name);
            if (item.app && item.app.runInTerminal)
                ProcessService.runDetached(["sh", "-c", Preferences.terminal + " -e " + item.app.command]);
            else if (item.app)
                item.app.execute();
        } else if (item.type === "workspace")
            Compositor.switchToWorkspace(item.workspaceIdx);
        else if (item.type === "window")
            Compositor.focusWindow(item.windowId);
        else if (item.type === "command" && item.action)
            item.action();
        else if (item.type === "command" && item.command)
            ProcessService.runDetached(item.command);
        else if (item.type === "web")
            ProcessService.runDetached(["xdg-open", item.url]);
    }

    Component.onCompleted: {
        fregFileView.reload();
    }

    fregFileView: FileView {
        path: root.frequencyFile
        watchChanges: false
        onLoadedChanged: {
            if (loaded) {
                try {
                    root.launchCounts = JSON.parse(text()) || {
                    };
                } catch (e) {
                }
            }
        }
    }


}
