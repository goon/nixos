import qs
import ".."
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ComboBox {
    id: root

    // Colors can be overridden
    property color textColor: Theme.colors.text
    property color backgroundColor: Theme.colors.background
    property color hoverColor: Theme.colors.muted
    property color borderColor: Theme.colors.border
    property color borderActiveColor: Theme.colors.primary
    // List limiting
    property int maxVisibleItems: 10

    // Search and Preview
    property bool searchable: false
    property bool previewFonts: false
    property string searchText: ""

    // Font settings
    readonly property string currentFontFamily: Theme.typography.family
    readonly property int currentFontPixelSize: Theme.typography.size.base
    readonly property int currentFontWeight: Theme.typography.weights.normal

    // Default sizing
    Layout.fillWidth: true
    implicitHeight: 42
    implicitWidth: 200

    font.family: currentFontFamily
    font.pixelSize: currentFontPixelSize
    font.weight: currentFontWeight
    
    enabled: count > 0
    opacity: enabled ? 1.0 : 0.5

    // Delegate (Dropdown items)
    delegate: ItemDelegate {
        id: delegateRoot
        width: ListView.view ? ListView.view.width : root.width
        height: isItemVisible ? 40 : 0

        property bool isItemVisible: {
            // FIX: Removed the index === root.currentIndex check which was hiding the active item!
            if (!root.searchable || root.searchText === "") return true;
            let t = (root.textRole && typeof modelData === "object") ? modelData[root.textRole] : modelData;
            return (t || "").toLowerCase().includes(root.searchText.toLowerCase());
        }

        visible: isItemVisible

        contentItem: BaseText {
            id: delegateText
            text: (root.textRole && typeof modelData === "object") ? modelData[root.textRole] : modelData
            color: delegateRoot.highlighted || delegateRoot.hovered ? Theme.colors.text : root.textColor
            weight: delegateRoot.highlighted || delegateRoot.hovered ? Theme.typography.weights.bold : Theme.typography.weights.normal
            
            // Lazy Font Loading
            property bool loadFont: !root.previewFonts
            
            Timer {
                id: lazyLoadTimer
                interval: 80
                running: root.previewFonts && delegateRoot.visible && !delegateText.loadFont && !listView.moving
                onTriggered: delegateText.loadFont = true
            }

            // Only preview if not moving to save CPU during scroll
            font.family: loadFont && root.previewFonts ? ((root.textRole && typeof modelData === "object") ? modelData[root.textRole] : modelData) : root.currentFontFamily
            font.pixelSize: root.currentFontPixelSize
            font.weight: root.currentFontWeight
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            leftPadding: Theme.geometry.spacing.dynamicPadding
            rightPadding: Theme.geometry.spacing.dynamicPadding
        }

        background: Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: Theme.geometry.radius
            
            visible: parent.highlighted || parent.hovered
            
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: Theme.alpha(Theme.colors.primary, 0.2) }
                GradientStop { position: 1; color: Theme.alpha(Theme.colors.secondary, 0.2) }
            }
            
            border.color: Theme.alpha(Theme.colors.primary, 0.5)
            border.width: 1
        }

        // Unified staggered opacity-only reveal
        opacity: comboPopup.opened ? 1.0 : 0.0
        Behavior on opacity {
            enabled: !listView.moving
            SequentialAnimation {
                PauseAnimation { duration: Math.min(delegateRoot.index * 12, 100) }
                NumberAnimation { duration: 150 }
            }
        }
    }

    // Main Content Item (Selected text)
    contentItem: BaseText {
        text: root.displayText
        color: root.textColor
        font.family: root.currentFontFamily
        font.pixelSize: root.currentFontPixelSize
        font.weight: root.currentFontWeight
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        leftPadding: Theme.geometry.spacing.dynamicPadding
        rightPadding: root.indicator.width + Theme.geometry.spacing.small
        visible: !comboPopup.visible
        opacity: visible ? 1.0 : 0.0
    }

    // Custom Chevron Indicator
    indicator: BaseIcon {
        x: root.width - width - Theme.geometry.spacing.medium
        y: (root.availableHeight - height) / 2
        icon: "expand_more"
        color: root.textColor
        size: Theme.dimensions.iconMedium
        visible: root.count > 0 && !comboPopup.visible
        opacity: visible ? 1.0 : 0.0
    }

    // Background (Border and fill)
    background: Rectangle {
        color: root.backgroundColor
        radius: Theme.geometry.radius
        border.color: root.activeFocus ? root.borderActiveColor : root.borderColor
        border.width: 1
        antialiasing: true
    }

    popup: Popup {
        id: comboPopup
        y: 0
        width: root.width
        implicitHeight: contentLayout.implicitHeight + padding * 2
        padding: Theme.geometry.spacing.medium

        // Seamless on-site transitions
        enter: Transition {
            NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 200; easing.type: Easing.OutQuint }
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
        }

        exit: Transition {
            NumberAnimation { property: "scale"; to: 0.95; duration: 150; easing.type: Easing.InQuint }
            NumberAnimation { property: "opacity"; to: 0; duration: 150 }
        }

        onOpened: {
            if (root.searchable) {
                searchInput.forceActiveFocus();
            }
        }

        onClosed: {
            root.searchText = "";
        }

        contentItem: ColumnLayout {
            id: contentLayout
            spacing: 0

            BaseInput {
                id: searchInput
                Layout.fillWidth: true
                Layout.margins: Theme.geometry.spacing.small
                Layout.preferredHeight: 36
                placeholderText: "Search..."
                visible: root.searchable
                onTextChanged: root.searchText = text
                
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        comboPopup.close();
                    } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                        // Select highlighted item
                        if (listView.count > 0) {
                            root.currentIndex = listView.currentIndex;
                            comboPopup.close();
                        }
                    }
                }
            }

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(contentHeight, 36 * root.maxVisibleItems)
                clip: true
                model: root.delegateModel
                currentIndex: root.highlightedIndex
                
                // Optimization for large font lists
                cacheBuffer: 100
                reuseItems: true

                ScrollBar.vertical: BaseScrollBar {
                }
            }
        }

        background: Rectangle {
            color: root.backgroundColor
            border.color: root.activeFocus ? root.borderActiveColor : root.borderColor
            border.width: 1
            antialiasing: true
            radius: Theme.geometry.radius
        }
    }
}
