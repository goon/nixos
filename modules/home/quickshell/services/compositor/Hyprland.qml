import QtQuick
import Quickshell
import Quickshell.Io
import qs
pragma Singleton

Singleton {
    id: root

    // Unified runner for Hyprland commands with error handling
    function runHyprJson(args, callback) {
        ProcessService.run(["hyprctl", "-j"].concat(args), function(data) {
            if (!data || data.trim() === "") {
                if (callback) callback([]);
                return;
            }
            try {
                var json = JSON.parse(data);
                if (callback) callback(json);
            } catch (e) {
                console.warn("Hyprland: Failed to parse JSON for", args, e);
                if (callback) callback([]);
            }
        });
    }

    // Signals for real-time updates
    signal workspacesUpdated(var workspaces, int activeId)
    signal windowsUpdated(var windows)
    signal focusedWindowUpdated(var window)

    // Internal state
    property var _currentWorkspaces: []
    property int _activeWorkspaceId: -1
    property var _wsIdToIdx: ({})

    // --- Event Stream ---
    // Using native hyprctl event-stream which is standard in recent Hyprland versions.
    Process {
        id: eventStream
        command: ["hyprctl", "event-stream"]
        running: true
        
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim()) processEvent(line.trim());
            }
        }
    }

    function processEvent(line) {
        var parts = line.split(">>");
        if (parts.length < 2) return;
        
        var event = parts[0];
        var data = parts[1];
        
        switch (event) {
            case "workspace":
            case "focusedmon":
                // data is workspace name or monitor name
                queryWorkspaces();
                break;
            case "activewindow":
            case "activewindowv2":
                queryFocusedWindow();
                break;
            case "openwindow":
            case "closewindow":
            case "movewindow":
            case "windowtitle":
            case "windowtitlev2":
                queryWindows();
                break;
            case "createworkspace":
            case "destroyworkspace":
            case "moveworkspace":
                queryWorkspaces();
                break;
        }
    }

    // --- State Mapping ---

    function queryWorkspaces(callback) {
        runHyprJson(["workspaces"], function(wsJson) {
            if (!Array.isArray(wsJson)) {
                if (callback) callback([], -1);
                return;
            }
            
            // Hyprland returns workspaces with name and id.
            // In Hyprland, 'id' is chronological/assigned, 'name' can be anything.
            // We'll treat numeric IDs as indices if possible.
            wsJson.sort((a, b) => a.id - b.id);
            
            var workspaces = wsJson.map(ws => {
                return {
                    "id": ws.id,
                    "idx": ws.id, // Using ID as index for simplicity
                    "name": ws.name || ws.id.toString(),
                    "isActive": false, // Updated by activeworkspace query
                    "isFocused": false,
                    "hasWindows": (ws.windows || 0) > 0,
                    "monitor": ws.monitor || ""
                };
            });

            // Now get active workspace
            runHyprJson(["activeworkspace"], function(activeJson) {
                var activeId = activeJson.id || -1;
                workspaces.forEach(ws => {
                    if (ws.id === activeId) {
                        ws.isActive = true;
                        ws.isFocused = true;
                    }
                });
                
                root._activeWorkspaceId = activeId;
                root._currentWorkspaces = workspaces;
                
                // Update ID to Index mapping for windows
                var mapping = {};
                workspaces.forEach(ws => mapping[ws.id] = ws.idx);
                root._wsIdToIdx = mapping;

                root.workspacesUpdated(workspaces, activeId);
                if (callback) callback(workspaces, activeId);
            });
        });
    }

    function queryWindows(callback) {
        runHyprJson(["clients"], function(clientsJson) {
            if (!Array.isArray(clientsJson)) {
                if (callback) callback([]);
                return;
            }

            var windows = clientsJson.map(win => {
                return {
                    "id": win.address, // Hyprland uses Hex addresses as unique IDs
                    "title": win.title || "",
                    "appId": win.class || "",
                    "pid": win.pid || -1,
                    "workspaceId": win.workspace.id || -1,
                    "workspaceIdx": win.workspace.id || -1,
                    "isFocused": false // Updated by activewindow query
                };
            });

            // Get active window to mark focus
            runHyprJson(["activewindow"], function(activeWin) {
                var activeAddr = activeWin.address || "";
                windows.forEach(w => {
                    if (w.id === activeAddr) w.isFocused = true;
                });
                
                root.windowsUpdated(windows);
                if (callback) callback(windows);
            });
        });
    }

    function queryFocusedWindow(callback) {
        runHyprJson(["activewindow"], function(win) {
            var mapped = null;
            if (win && win.address) {
                mapped = {
                    "id": win.address,
                    "title": win.title || "",
                    "app": win.class || ""
                };
            }
            root.focusedWindowUpdated(mapped);
            if (callback) callback(mapped);
        });
    }

    // --- Actions ---

    function switchToWorkspace(workspaceIdx) {
        // Hyprland handles workspace switching via dispatcher
        ProcessService.runDetached(["hyprctl", "dispatch", "workspace", workspaceIdx.toString()]);
    }

    function focusWindow(windowId) {
        // In Hyprland windowId is the address (e.g. 0x55...)
        ProcessService.runDetached(["hyprctl", "dispatch", "focuswindow", "address:" + windowId]);
    }

    function quit() {
        ProcessService.runDetached(["hyprctl", "dispatch", "exit"]);
    }

    Component.onCompleted: {
        queryWorkspaces();
        queryWindows();
        queryFocusedWindow();
    }
}
