import QtQuick
import Quickshell
import Quickshell.Io
import qs
pragma Singleton

Singleton {
    id: root

    // Unified runner for Niri commands with error handling
    function runNiriJson(args, callback) {
        ProcessService.run(["niri", "msg", "--json"].concat(args), function(data) {
            if (!data || data.trim() === "") {
                if (callback)
                    callback([]);

                return ;
            }
            try {
                var json = JSON.parse(data);
                if (callback)
                    callback(json);

            } catch (e) {
                if (callback)
                    callback([]);

            }
        });
    }

    // Signals for real-time updates
    signal workspacesUpdated(var workspaces, int activeId)
    signal windowsUpdated(var windows)
    signal focusedWindowUpdated(var window)

    // Internal caching for performance
    property var _windowsToWsCache: ({})
    property var _currentWorkspaces: []

    Process {
        id: eventStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim()) processEvent(line.trim());
            }
        }
    }

    function processEvent(jsonStr) {
        try {
            var event = JSON.parse(jsonStr);
            if (event.WorkspacesChanged) {
                handleWorkspacesUpdate(event.WorkspacesChanged.workspaces);
            } else if (event.WorkspaceActivated) {
                var activeId = event.WorkspaceActivated.id;
                // Update local state and emit immediately
                for (var i = 0; i < root._currentWorkspaces.length; i++) {
                    root._currentWorkspaces[i].isActive = (root._currentWorkspaces[i].id === activeId);
                    root._currentWorkspaces[i].isFocused = (root._currentWorkspaces[i].id === activeId);
                }
                root.workspacesUpdated(root._currentWorkspaces, activeId);
                // Trigger a refresh just to stay perfectly in sync, but the UI is already updated
                queryWorkspaces();
            } else if (event.WindowsChanged) {
                handleWindowsUpdate(event.WindowsChanged.windows);
            } else if (event.WindowOpenedOrChanged || event.WindowClosed || event.WindowFocused || event.WindowFocusChanged || event.WindowLayoutsChanged || event.WindowFocusTimestampChanged) {
                queryWindows();
                queryFocusedWindow();
            } else if (event.WorkspaceAdded || event.WorkspaceRemoved || event.WorkspaceMovedToOutput) {
                queryWorkspaces();
            }
        } catch (e) {
            console.warn("Niri: Failed to parse event", e);
        }
    }

    function handleWorkspacesUpdate(wsJson) {
        if (!Array.isArray(wsJson)) return;
        
        wsJson.sort((a, b) => (a.idx || 0) - (b.idx || 0));
        
        var activeId = -1;
        var workspaces = wsJson.map((ws) => {
            if (ws.is_focused || ws.is_active) activeId = ws.id;
            return {
                "id": ws.id,
                "idx": ws.idx,
                "name": ws.name || ("WS" + ws.idx),
                "isActive": ws.is_active || false,
                "isFocused": ws.is_focused || false,
                "hasWindows": (root._windowsToWsCache[ws.id] || 0) > 0,
                "windowTitles": [] // Titles are heavy, we can skip for the real-time pill
            };
        });
        
        root._currentWorkspaces = workspaces;
        root.workspacesUpdated(workspaces, activeId);
    }

    function handleWindowsUpdate(json) {
        if (!Array.isArray(json)) return;
        
        var newCache = {};
        
        // Create a map of workspace ID to its index for fast lookup
        var wsIdToIdx = {};
        root._currentWorkspaces.forEach(ws => {
            wsIdToIdx[ws.id] = ws.idx;
        });

        var windows = json.map((win) => {
            var wid = win.workspace_id;
            if (wid !== undefined) {
                newCache[wid] = (newCache[wid] || 0) + 1;
            }

            var colIdx = (win.layout && win.layout.pos_in_scrolling_layout) ? win.layout.pos_in_scrolling_layout[0] : 0;
            return {
                "id": win.id,
                "title": win.title || "",
                "appId": win.app_id || "",
                "pid": win.pid || -1,
                "workspaceId": win.workspace_id || -1,
                "workspaceIdx": (wid !== undefined) ? (wsIdToIdx[wid] ?? -1) : -1,
                "isFocused": win.is_focused === true,
                "colIdx": colIdx
            };
        });
        
        root._windowsToWsCache = newCache;
        root.windowsUpdated(windows);
    }

    // Query workspaces from Niri
    function queryWorkspaces(callback) {
        runNiriJson(["workspaces"], function(wsJson) {
            if (!Array.isArray(wsJson)) {
                if (callback) callback([], -1);
                return;
            }
            handleWorkspacesUpdate(wsJson);
            // We still support callback for manual refreshes
            if (callback) {
                var handler = function(ws, activeId) {
                    callback(ws, activeId);
                    root.workspacesUpdated.disconnect(handler);
                };
                root.workspacesUpdated.connect(handler);
            }
        });
    }

    // Query windows from Niri
    function queryWindows(callback) {
        runNiriJson(["windows"], function(json) {
            if (!Array.isArray(json)) {
                if (callback) callback([]);
                return;
            }
            handleWindowsUpdate(json);
            if (callback) {
                var handler = function(wins) {
                    callback(wins);
                    root.windowsUpdated.disconnect(handler);
                };
                root.windowsUpdated.connect(handler);
            }
        });
    }

    // Query focused window
    function queryFocusedWindow(callback) {
        runNiriJson(["windows"], function(json) {
            if (!Array.isArray(json)) {
                if (callback) callback(null);
                return;
            }
            var focused = json.find(w => w.is_focused);
            var mapped = null;
            if (focused) {
                mapped = {
                    "id": focused.id,
                    "title": focused.title || "",
                    "app": focused.app_id || ""
                };
            }
            if (callback) callback(mapped);
            root.focusedWindowUpdated(mapped);
        });
    }

    // Switch to workspace
    function switchToWorkspace(workspaceIdx) {
        ProcessService.runDetached(["niri", "msg", "action", "focus-workspace", workspaceIdx.toString()]);
    }

    // Focus window by ID
    function focusWindow(windowId) {
        ProcessService.runDetached(["niri", "msg", "action", "focus-window", "--id", windowId.toString()]);
    }

    // Quit Niri session
    function quit() {
        ProcessService.runDetached(["niri", "msg", "action", "quit", "--skip-confirmation"]);
    }

}
