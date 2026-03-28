import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs

FocusScope {
    id: root

    // --- Public Interface ---
    property string searchText: ""
    property bool isActive: false
    property var currentItem: null
    property var listView: null // Derived components should alias this to their list view
    property list<Item> pageHints // Can be overridden by tabs to provide hints like "Del", "Enter"
    
    property int listCount: {
        var view = root.listView;
        if (!view) return 0;
        
        // Prioritize model length if available (more stable during filtering)
        if (view.model) {
            if (typeof view.model.count !== 'undefined') return view.model.count;
            if (typeof view.model.length !== 'undefined') return view.model.length;
        }
        
        // Fallback to view count
        if (typeof view.count !== 'undefined') return view.count;
        
        return 0;
    }

    signal closeRequested()
    signal mouseMoveRequested(int index, var mouse)
    signal tabRedirectRequested(int index)

    // --- State Management ---
    visible: opacity > 0
    opacity: isActive ? 1 : 0
    
    Behavior on opacity {
        BaseAnimation {
            duration: Theme.animations.normal
        }
    }

    onIsActiveChanged: {
        if (isActive) {
            LauncherService.resetInputStates();
            LauncherService.lastInputMethod = "keyboard";
            onActivated();
        } else {
            onDeactivated();
        }
    }

    // --- Virtual Methods (to be overridden if needed) ---
    
    // Called when the tab becomes active
    function onActivated() {
        if (root.listView) {
            if (root.listView.count > 0 && root.listView.currentIndex === -1) {
                root.listView.currentIndex = 0;
            }
        }
    }

    // Called when the tab becomes inactive
    function onDeactivated() {
        // Default nothing
    }

    // Called when the overall launcher window is closed
    function onLauncherClosed() {
        // Default nothing
    }

    // Called to trigger search/filter logic
    function performSearch() {
        console.warn("LauncherTab: performSearch() not implemented for " + root);
    }

    // Called when Enter is pressed
    function activateCurrentItem() {
        console.warn("LauncherTab: activateCurrentItem() not implemented for " + root);
    }
}
