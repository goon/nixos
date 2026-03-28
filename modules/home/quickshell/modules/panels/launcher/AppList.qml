import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs

LauncherTab {
    id: root

    // --- Tab Configuration ---
    property bool includeWindows: false
    
    // Alias for the list view so the parent (Launcher.qml) can control it
    listView: appListView

    // --- Internal Properties ---
    property var cachedModel: []
    property string _lastQuery: ""
    property string specialMode: ""
    property string specialModeText: ""

    // --- Search Handling ---
    
    onSearchTextChanged: {
        searchDebounceTimer.restart();
    }

    // Called by the base class when this tab becomes active
    function onActivated() {
        if (root.searchText.trim() === "")
            appListView.currentIndex = 0;

        performSearch();
        
        if (appListView.count > 0 && appListView.currentIndex === -1)
             appListView.currentIndex = 0;
    }

    // Override the base performSearch
    function performSearch() {
        var query = root.searchText.trim();
        var queryChanged = query !== _lastQuery;
        _lastQuery = query;

        // 1. Command Mode
        if (LauncherService.isCommandMode(query)) {
            specialMode = "command";
            specialModeText = LauncherService.getCommandText(query);
            appListView.currentIndex = -1;
            return;
        }

        specialMode = "";
        specialModeText = "";

        // 2. Calculator & App Search
        var calcResult = LauncherService.evaluateCalculator(query);
        var appResults = [];

        if (root.includeWindows) {
            Compositor.queryWorkspaces((workspaces) => {
                appResults = LauncherService.searchApps(query, DesktopEntries.applications.values, workspaces, Config.launcherMaxResults || 100);
                finalizeModel(calcResult, appResults, queryChanged);
            });
        } else {
            appResults = LauncherService.searchApps(query, DesktopEntries.applications.values, null, Config.launcherMaxResults || 100);
            finalizeModel(calcResult, appResults, queryChanged);
        }
    }

    function finalizeModel(calcResult, appResults, queryChanged) {
        var newModel = [];
        if (calcResult !== null) {
            newModel.push({
                "type": "calculation",
                "name": calcResult.toString(),
                "description": "Result - Copy to clipboard",
                "icon": "calculate"
            });
        }
        
        for (var i = 0; i < appResults.length; i++) {
            newModel.push(appResults[i]);
        }
        
        cachedModel = newModel;
        updateCurrentIndex(queryChanged);
    }

    function updateCurrentIndex(queryChanged) {
        if (queryChanged || appListView.currentIndex === -1) {
            if (cachedModel.length > 0)
                appListView.currentIndex = 0;
            else
                appListView.currentIndex = -1;
        }
    }

    // Override base activateCurrentItem
    function activateCurrentItem() {
        searchDebounceTimer.stop();
        performSearch(); // Ensure state is fresh

        if (appListView.currentIndex < 0 && cachedModel.length > 0)
            appListView.currentIndex = 0;

        if (specialMode === "command") {
            if (specialModeText.length > 0) {
                ProcessService.runDetached([Preferences.terminal, "-e", "sh", "-c", specialModeText + "; read"]);
                root.closeRequested();
            }
        } else if (appListView.currentIndex >= 0 && cachedModel && appListView.currentIndex < cachedModel.length) {
            var item = cachedModel[appListView.currentIndex];
            if (item.type === "calculation") {
                ProcessService.runDetached(["wl-copy", item.name]);
                root.closeRequested();
            } else {
                LauncherService.executeItem(item);
                root.closeRequested();
            }
        }
    }

    // --- Sub-Components ---

    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            if (root.isActive) performSearch();
        }
    }

    Timer {
        id: searchDebounceTimer
        interval: 100
        repeat: false
        onTriggered: performSearch()
    }

    LauncherListView {
        id: appListView
        anchors.fill: parent
        model: cachedModel
        
        // Handle special modes logic for selection
        onCountChanged: {
             if (LauncherService.lastInputMethod === "keyboard" || currentIndex === -1) {
                if (count > 0 && currentIndex < 0 && specialMode === "")
                    currentIndex = 0;
                else if (count === 0)
                    currentIndex = -1;
            }
        }

        delegate: LauncherItemDelegate {
            itemIndex: index
            selected: appListView.currentIndex === index
            
            // App Logic
            text: modelData ? modelData.name : ""
            
            property bool isWorkspace: (modelData && modelData.type === "workspace")
            property bool isCalculation: (modelData && modelData.type === "calculation")
            
            iconSource: isCalculation ? "calculate" : (isWorkspace ? "view_carousel" : "")
            imageSource: (!isWorkspace && !isCalculation && modelData) ? LauncherService.resolveIcon(modelData.icon) : ""
            
            showFallbackIcon: (imageSource === "") && !isCalculation && !isWorkspace
            boxedIcon: isCalculation || isWorkspace
            fallbackText: (modelData && modelData.name && modelData.name.length > 0) ? modelData.name.charAt(0).toUpperCase() : "?"
            
            onClicked: {
                appListView.currentIndex = index;
                root.activateCurrentItem();
            }
        }

    }
}
