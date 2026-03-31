import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
pragma Singleton

Singleton {
    id: root

    // Signals for real-time updates (Unified interface)
    signal workspacesUpdated(var workspaces, int activeId)
    signal windowsUpdated(var windows)
    signal focusedWindowUpdated(var window)

    property var _currentWorkspaces: []

    // Helper to map native workspaces to our unified format
    function mapWorkspaces() {
        var res = [];
        var activeId = -1;
        var maxId = 0;
        var focusedWs = Hyprland.focusedWorkspace;
        if (focusedWs) {
            activeId = focusedWs.id;
            if (activeId > 0) maxId = activeId;
        }

        var wsMap = {};
        var wsList = Hyprland.workspaces.values;
        for (var i = 0; i < wsList.length; i++) {
            var ws = wsList[i];
            if (ws.id < 0) continue; // Skip special
            
            wsMap[ws.id] = {
                "id": ws.id,
                "idx": ws.id,
                "name": ws.name || ws.id.toString(),
                "isActive": ws.active,
                "isFocused": ws.focused,
                "hasWindows": ws.toplevels.values.length > 0,
                "monitor": ws.monitor ? ws.monitor.name : ""
            };
            if (ws.id > maxId) maxId = ws.id;
        }

        // Pad the list up to maxId
        for (var id = 1; id <= maxId; id++) {
            if (wsMap[id]) {
                res.push(wsMap[id]);
            } else {
                res.push({
                    "id": id,
                    "idx": id,
                    "name": id.toString(),
                    "isActive": false,
                    "isFocused": false,
                    "hasWindows": false,
                    "monitor": ""
                });
            }
        }

        res.sort((a, b) => a.id - b.id);
        return { list: res, activeId: activeId };
    }

    // Helper to map native toplevels to our unified format
    function mapWindows() {
        var res = [];
        var tlList = Hyprland.toplevels.values;
        
        for (var i = 0; i < tlList.length; i++) {
            var win = tlList[i];
            
            // Collect appId from multiple sources. 
            // We'll prioritize the IPC class as it's the standard for Hyprland rules/icons.
            var appId = "";
            if (win.lastIpcObject && win.lastIpcObject.class) {
                appId = win.lastIpcObject.class;
            } else if (win.wayland && win.wayland.appId) {
                appId = win.wayland.appId;
            } else if (win["class"]) {
                appId = win["class"];
            }

            // If appId is still empty, skip this window for now.
            // This prevents Dock.qml from showing a fallback icon and getting stuck with poor scaling.
            // The retry timer will pick it up once metadata is populated.
            if (appId === "") continue;

            res.push({
                "id": win.address,
                "title": win.title || "",
                "appId": appId,
                "pid": 0,
                "workspaceId": win.workspace ? win.workspace.id : -1,
                "workspaceIdx": win.workspace ? win.workspace.id : -1,
                "isFocused": win.activated
            });
        }
        return res;
    }

    // --- State Bridging ---
    Connections {
        target: Hyprland.workspaces
        function onObjectInsertedPost() { triggerWorkspacesUpdate(); }
        function onObjectRemovedPost() { triggerWorkspacesUpdate(); }
    }

    Connections {
        target: Hyprland.toplevels
        function onObjectInsertedPost() { 
            Hyprland.refreshToplevels(); 
            triggerWindowsUpdate(); 
            retryUpdateTimer.restart();
        }
        function onObjectRemovedPost() { triggerWindowsUpdate(); }
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() { triggerWorkspacesUpdate(); }
        function onActiveToplevelChanged() { 
            triggerWindowsUpdate(); 
            triggerFocusedWindowUpdate();
            retryUpdateTimer.restart();
        }
    }

    Timer {
        id: retryUpdateTimer
        interval: 300
        repeat: false
        onTriggered: {
            triggerWindowsUpdate();
            triggerFocusedWindowUpdate();
        }
    }

    function triggerWorkspacesUpdate() {
        var data = mapWorkspaces();
        root._currentWorkspaces = data.list;
        root.workspacesUpdated(data.list, data.activeId);
    }

    function triggerWindowsUpdate() {
        var data = mapWindows();
        root.windowsUpdated(data);
    }

    function triggerFocusedWindowUpdate() {
        var win = Hyprland.activeToplevel;
        var mapped = null;
        if (win) {
            mapped = {
                "id": win.address,
                "title": win.title || "",
                "app": (win.lastIpcObject && win.lastIpcObject.class) ? win.lastIpcObject.class : (win.wayland ? win.wayland.appId : "")
            };
        }
        root.focusedWindowUpdated(mapped);
    }

    // --- Actions (Unified Interface) ---
    function switchToWorkspace(workspaceIdx) {
        Hyprland.dispatch("workspace " + workspaceIdx);
    }

    function focusWindow(windowId) {
        var addr = windowId;
        if (!addr.startsWith("0x")) addr = "0x" + addr;
        Hyprland.dispatch("focuswindow address:" + addr);
    }

    function quit() {
        Hyprland.dispatch("exit");
    }

    // --- Initial Polling / Manual Refresh ---
    function queryWorkspaces(callback) {
        var data = mapWorkspaces();
        if (callback) callback(data.list, data.activeId);
        root.workspacesUpdated(data.list, data.activeId);
    }

    function queryWindows(callback) {
        var data = mapWindows();
        if (callback) callback(data);
        root.windowsUpdated(data);
    }

    function queryFocusedWindow(callback) {
        var win = Hyprland.activeToplevel;
        var mapped = null;
        if (win) {
            mapped = {
                "id": win.address,
                "title": win.title || "",
                "app": (win.lastIpcObject && win.lastIpcObject.class) ? win.lastIpcObject.class : (win.wayland ? win.wayland.appId : "")
            };
        }
        if (callback) callback(mapped);
        root.focusedWindowUpdated(mapped);
    }

    Component.onCompleted: {
        Hyprland.refreshWorkspaces();
        Hyprland.refreshToplevels();
        triggerWorkspacesUpdate();
        triggerWindowsUpdate();
        triggerFocusedWindowUpdate();
    }
}
