import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs

LauncherTab {
    id: root

    // --- Tab Configuration ---
    listView: themeListView
    
    // --- Logic ---
    function performSearch() {
        // Handled by binding
    }
    
    function activateCurrentItem() {
        if (themeListView && themeListView.model) {
            if (themeListView.currentIndex < 0 && themeListView.count > 0)
                themeListView.currentIndex = 0;
        }
        if (themeListView && themeListView.currentIndex >= 0 && themeListView.currentIndex < themeListView.model.length) {
            ThemeService.setTheme(themeListView.model[themeListView.currentIndex].id);
            root.closeRequested();
        }
    }

    LauncherListView {
        id: themeListView
        anchors.fill: parent
        
        model: {
            const allThemes = ThemeService.allThemes || [];
            if (!root.searchText)
                return allThemes;

            var results = [];
            var query = root.searchText.toLowerCase();
            for (var i = 0; i < allThemes.length; i++) {
                var theme = allThemes[i];
                if (theme.name && theme.name.toLowerCase().indexOf(query) !== -1)
                    results.push(theme);
            }
            return results;
        }
        
        // Auto-select first item logic (replicated partly in LauncherTab but good to keep specific here if needed)
        onCountChanged: {
            if (LauncherService.lastInputMethod === "keyboard") {
                if (count > 0) {
                    if (currentIndex < 0) currentIndex = 0;
                } else {
                    currentIndex = -1;
                }
            }
        }

        delegate: LauncherItemDelegate {
            id: delegateItem
            itemIndex: index
            selected: themeListView.currentIndex === index
            
            readonly property var themeColors: (modelData && modelData.colors) ? modelData.colors : {}
            
            text: "" 
            iconSource: ""

            width: themeListView.width
            height: 54
            
            // Custom Content Overlay
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.geometry.spacing.dynamicPadding
                anchors.rightMargin: Theme.geometry.spacing.dynamicPadding
                spacing: Theme.geometry.spacing.medium

                BaseIcon {
                    icon: "palette"
                    size: Theme.dimensions.iconMedium
                    color: delegateItem.selected ? Theme.colors.primary : Theme.colors.muted
                    Layout.alignment: Qt.AlignVCenter
                }

                BaseText {
                    text: (modelData && modelData.name) ? modelData.name : ""
                    color: delegateItem.selected ? Theme.colors.text : Theme.colors.muted
                    weight: delegateItem.selected ? Theme.typography.weights.bold : Theme.typography.weights.normal
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    elide: Text.ElideRight
                }

                Row {
                    spacing: 6
                    Layout.alignment: Qt.AlignVCenter

                    Repeater {
                        model: {
                            var pIdx = (delegateItem.themeColors && delegateItem.themeColors.primaryIdx) ? delegateItem.themeColors.primaryIdx : "base0D";
                            var sIdx = (delegateItem.themeColors && delegateItem.themeColors.secondaryIdx) ? delegateItem.themeColors.secondaryIdx : "base0E";
                            return ["base00", "base01", pIdx, sIdx, "base0A"];
                        }
                        Rectangle {
                            width: Theme.dimensions.iconSmall
                            height: Theme.dimensions.iconSmall
                            radius: 7
                            color: (delegateItem.themeColors && delegateItem.themeColors[modelData]) ? delegateItem.themeColors[modelData] : Theme.colors.transparent
                            visible: !!(delegateItem.themeColors && delegateItem.themeColors[modelData])
                            border.width: 1
                            border.color: Qt.alpha(Theme.colors.text, 0.1)
                        }
                    }
                }
            }

            onClicked: {
                themeListView.currentIndex = index;
                root.activateCurrentItem();
            }
        }

    }
}
