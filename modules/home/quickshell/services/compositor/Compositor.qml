import QtQuick
import Quickshell
import Quickshell.Io
import qs
pragma Singleton

QtObject {
    // --- Niri Unified Logic ---
    // --- State Management ---
    // --- Backend Delegation ---
    // --- State Management ---

    id: root

    // "niri", etc.
    property string name: ""
    property bool isReady: false
    // Active Compositor singleton (Niri, etc.)
    property var backend: null
    // Unified State
    property var workspaces: []
    property var windows: []
    property int activeWorkspaceId: -1
    property var activeWindow: ({
        "title": "Desktop",
        "app": ""
    })
    // Inherited Opacity from Niri
    property real opacity: 1
    property Timer pollTimer

    function queryWorkspaces(callback) {
        if (backend) backend.queryWorkspaces(callback);
    }

    function queryWindows(callback) {
        if (backend) backend.queryWindows(callback);
    }

    function queryFocusedWindow(callback) {
        if (backend) backend.queryFocusedWindow(callback);
    }

    function switchToWorkspace(workspaceIdx) {
        if (backend) {
            backend.switchToWorkspace(workspaceIdx);
            // No need for manual refresh, event stream will catch it
        }
    }

    function focusWindow(windowId) {
        if (backend) backend.focusWindow(windowId);
    }

    function quit() {
        if (backend) backend.quit();
    }

    function refresh() {
        queryWorkspaces(function(ws, activeId) {
            root.workspaces = ws;
            root.activeWorkspaceId = activeId;
        });
        queryWindows(function(wins) {
            // Sort windows by workspace index, then by their horizontal position (colIdx)
            var sortedWins = wins.slice().sort((a, b) => {
                var idxA = a.workspaceIdx;
                var idxB = b.workspaceIdx;

                // Fallback to workspace list if index is unknown
                if (idxA === -1) {
                    var wsA = root.workspaces.find(ws => ws.id === a.workspaceId);
                    if (wsA) idxA = wsA.idx;
                }
                if (idxB === -1) {
                    var wsB = root.workspaces.find(ws => ws.id === b.workspaceId);
                    if (wsB) idxB = wsB.idx;
                }

                if (idxA !== idxB) {
                    return idxA - idxB;
                }
                if (a.colIdx !== b.colIdx) {
                    return a.colIdx - b.colIdx;
                }
                return a.id - b.id; // Deterministic tie-breaker
            });
            root.windows = sortedWins;
        });
        queryFocusedWindow(function(win) {
            if (win)
                root.activeWindow = {
                "title": win.title || "Desktop",
                "app": win.app || ""
            };
            else
                root.activeWindow = {
                "title": "Desktop",
                "app": ""
            };
        });
    }

    Component.onCompleted: {
        // Dynamic Detection
        var isHyprland = !!Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE");
        var isNiri = !!Quickshell.env("NIRI_SOCKET");
        
        if (isHyprland) {
            root.name = "hyprland";
            root.backend = Hyprland;
        } else if (isNiri) {
            root.name = "niri";
            root.backend = Niri;
        } else {
            console.warn("Compositor: Unknown environment. Defaulting to Niri.");
            root.name = "niri";
            root.backend = Niri;
        }

        root.isReady = true;

        // Connect to real-time signals
        if (root.backend) {
            root.backend.workspacesUpdated.connect((ws, activeId) => {
                root.workspaces = ws;
                root.activeWorkspaceId = activeId;
            });
            root.backend.windowsUpdated.connect((wins) => {
                var sortedWins = wins.slice().sort((a, b) => {
                    var idxA = a.workspaceIdx;
                    var idxB = b.workspaceIdx;

                    if (idxA === -1) {
                        var wsA = root.workspaces.find(ws => ws.id === a.workspaceId);
                        if (wsA) idxA = wsA.idx;
                    }
                    if (idxB === -1) {
                        var wsB = root.workspaces.find(ws => ws.id === b.workspaceId);
                        if (wsB) idxB = wsB.idx;
                    }

                    if (idxA !== idxB) return idxA - idxB;
                    if (a.colIdx !== b.colIdx) return a.colIdx - b.colIdx;
                    return a.id - b.id; // Deterministic tie-breaker
                });
                root.windows = sortedWins;
            });
            root.backend.focusedWindowUpdated.connect((win) => {
                if (win) root.activeWindow = { "title": win.title || "Desktop", "app": win.app || "" };
                else root.activeWindow = { "title": "Desktop", "app": "" };
            });
        }

        root.refresh();
    }

    // Internal Polling - High-interval safety fallback
    pollTimer: Timer {
        interval: 5000 // Only for periodic sync check
        running: root.isReady
        repeat: true
        onTriggered: root.refresh()
    }

}
