import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.services
import qs

LauncherTab {
    id: root

    // --- Tab Configuration ---
    listView: clipboardListView


    // --- Internal Properties ---
    property var currentItem: (clipboardListView.currentIndex >= 0 && filteredModel.count > 0) ? filteredModel.get(clipboardListView.currentIndex) : null

    // --- Logic ---
    onSearchTextChanged: {
        clipboardListView.currentIndex = 0;
        updateFilteredModel();
    }
    
    function onActivated() {
        clipboardListView.currentIndex = 0;
        root.forceActiveFocus(); // Ensure we catch keys
    }

    function activateCurrentItem() {
        if (root.currentItem) {
            Clipboard.copyToClipboard(root.currentItem.clipboardContent);
            root.closeRequested();
        }
    }
    
    function performSearch() {
        // Handled by model filtering update
    }

    // --- Special Clipboard Actions ---
    function deleteCurrentItem() {
        if (clipboardListView.currentIndex >= 0 && filteredModel.count > 0) {
            var item = filteredModel.get(clipboardListView.currentIndex);
            // We need to find the actual index in the Clipboard service history
            for (var i = 0; i < Clipboard.history.count; i++) {
                if (Clipboard.history.get(i).text === item.clipboardContent) {
                    Clipboard.deleteItem(i);
                    break;
                }
            }
        }
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Delete) {
            if (event.modifiers & Qt.ControlModifier) {
                Clipboard.clearHistory();
            } else {
                root.deleteCurrentItem();
            }
            event.accepted = true;
        }
    }

    // Filtered model for search
    ListModel {
        id: filteredModel
    }

    function updateFilteredModel() {
        filteredModel.clear();
        var query = root.searchText.toLowerCase();
        for (var i = 0; i < Clipboard.history.count; i++) {
            var item = Clipboard.history.get(i);
            if (!query || item.text.toLowerCase().indexOf(query) !== -1) {
                filteredModel.append({
                    "name": item.text.replace(/\n/g, " ").substring(0, 100),
                    "clipboardContent": item.text,
                    "description": item.isImage ? "Image file" : "Text snippet",
                    "icon": item.isImage ? "image" : "content_copy",
                    "category": "Clipboard",
                    "type": "clipboard"
                });
            }
        }
    }

    Connections {
        target: Clipboard.history
        function onCountChanged() { updateFilteredModel() }
        function onDataChanged() { updateFilteredModel() }
    }

    Component.onCompleted: updateFilteredModel()

    LauncherListView {
        id: clipboardListView
        anchors.fill: parent
        model: filteredModel

        delegate: LauncherItemDelegate {
            itemIndex: index
            selected: clipboardListView.currentIndex === index
            
            text: model.name
            subText: model.description
            iconSource: model.icon

            onClicked: {
                clipboardListView.currentIndex = index;
                root.activateCurrentItem();
            }
        }

    }
}
