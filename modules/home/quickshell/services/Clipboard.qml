import QtQuick
import Quickshell
import Quickshell.Io
import qs
pragma Singleton

QtObject {
    id: root

    property ListModel history
    readonly property string historyFile: Config.cacheDir + "/clipboard-history.json"
    readonly property string imagesDir: Config.cacheDir + "/clipboard-images"
    property int maxItems: 50
    property string _lastText: ""
    property string _lastImageHash: ""
    // Persistence
    property FileView historyFileView
    property Timer pollTimer

    function saveHistory() {
        var data = [];
        for (var i = 0; i < history.count; i++) {
            data.push(history.get(i).text);
        }
        // Ensure directory exists then write via ProcessService because FileView might fail on new dirs
        var jsonStr = JSON.stringify(data);
        ProcessService.runDetached(["sh", "-c", "mkdir -p \"$(dirname \"$2\")\"; echo \"$1\" > \"$2\"", "--", jsonStr, root.historyFile]);
    }

    function addClip(text) {
        if (!text || text === "" || text === _lastText)
            return ;

        // Remove existing if duplicate
        for (var i = 0; i < history.count; i++) {
            if (history.get(i).text === text) {
                history.remove(i);
                break;
            }
        }
        var isImage = text.match(/\.(png|jpg|jpeg|gif|bmp|svg|webp)$/i) && (text.startsWith("/") || text.startsWith("file://"));
        history.insert(0, {
            "text": text,
            "isImage": !!isImage
        });
        _lastText = text;
        if (history.count > maxItems)
            history.remove(maxItems, history.count - maxItems);

        saveHistory();
    }

    function copyToClipboard(text) {
        if (!text)
            return ;

        _lastText = text; // Prevent immediate re-add
        ProcessService.runDetached(["sh", "-c", "printf '%s' \"$1\" | wl-copy", "--", text]);
    }

    function deleteItem(index) {
        if (index >= 0 && index < history.count) {
            history.remove(index);
            saveHistory();
        }
    }

    function clearHistory() {
        history.clear();
        saveHistory();
    }

    Component.onCompleted: {
        historyFileView.reload();
    }

    history: ListModel {
    }

    historyFileView: FileView {
        path: root.historyFile
        watchChanges: false
        onLoadedChanged: {
            if (loaded) {
                try {
                    var data = JSON.parse(text());
                    if (Array.isArray(data)) {
                        root.history.clear();
                        for (var i = 0; i < data.length; i++) {
                            var textVal = data[i];
                            var isImg = textVal.match(/\.(png|jpg|jpeg|gif|bmp|svg|webp)$/i) && (textVal.startsWith("/") || textVal.startsWith("file://"));
                            root.history.append({
                                "text": textVal,
                                "isImage": !!isImg
                            });
                        }
                    }
                } catch (e) {
                    // console.error("Clipboard: Failed to load history:", e.message);
                }
            }
        }
    }

    pollTimer: Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            // 1. Try to get text
            ProcessService.run(["wl-paste", "-n", "-t", "text"], function(out) {
                if (out !== undefined && out !== null) {
                    var text = out.trim();
                    if (text !== "" && text !== _lastText) {
                        addClip(text);
                        return ; // Found text, skip image check for this tick
                    }
                }
                // 2. No new text, check for image/png
                ProcessService.run(["sh", "-c", "wl-paste -l | grep -q 'image/png' && wl-paste -t image/png | md5sum"], function(hashOut) {
                    if (hashOut && hashOut.indexOf(" ") !== -1) {
                        var hash = hashOut.split(" ")[0];
                        if (hash !== _lastImageHash) {
                            var filename = "clip_" + Date.now() + ".png";
                            var fullPath = root.imagesDir + "/" + filename;
                            // Save the image
                            ProcessService.runDetached(["sh", "-c", "mkdir -p \"$1\"; wl-paste -t image/png > \"$2\"", "--", root.imagesDir, fullPath]);
                            _lastImageHash = hash;
                            // Add to history as a file path
                            addClip(fullPath);
                        }
                    }
                });
            });
        }
    }

}
