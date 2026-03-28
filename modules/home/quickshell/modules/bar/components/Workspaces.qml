import "../../../components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

Item {
    id: root

    // Centralized state from Compositor service
    readonly property var workspaces: {
        var rawList = Compositor.workspaces || [];
        return rawList;
    }
    readonly property int activeWorkspaceId: localActiveId !== -1 ? localActiveId : Compositor.activeWorkspaceId
    property int localActiveId: -1

    // Instantly sync local state when the compositor's event arrives
    Connections {
        target: Compositor
        function onActiveWorkspaceIdChanged() {
            if (Compositor.activeWorkspaceId === localActiveId) {
                localActiveId = -1;
            }
        }
    }

    // Timer to reset local state if the event never arrives (safety fallback)
    Timer {
        id: syncTimer
        interval: 1000
        onTriggered: localActiveId = -1
    }

    function toRoman(n) {
        if (!n || n <= 0) return n;
        var mapping = [
            [10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"]
        ];
        var res = "";
        for (var i = 0; i < mapping.length; i++) {
            while (n >= mapping[i][0]) {
                res += mapping[i][1];
                n -= mapping[i][0];
            }
        }
        return res;
    }

    function toKanji(n) {
        if (!n || n <= 0) return n;
        var digits = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"];
        if (n < 10) return digits[n];
        if (n === 10) return "十";
        if (n < 20) return "十" + digits[n % 10];
        var tens = Math.floor(n / 10);
        var units = n % 10;
        return (tens > 1 ? digits[tens] : "") + "十" + digits[units];
    }

    Layout.fillWidth: false
    // Ensure standard bar height and vertical alignment
    implicitHeight: 32
    implicitWidth: layout.implicitWidth

    // Shared Selection Blob (The "Gooey" indicator)
    Rectangle {
        id: selectionBlob
        z: 0
        radius: Theme.geometry.radius
        height: Theme.dimensions.barItemHeight
        
        // Find the active item to get its geometry
        property Item activeItem: null
        
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: Theme.colors.primary }
            GradientStop { position: 1; color: Theme.colors.secondary }
        }

        // Parent is the root Item, so we offset by layout.x
        x: layout.x + (activeItem ? activeItem.x : 0)
        width: activeItem ? activeItem.width : 55
        visible: activeItem !== null

        Behavior on x { 
            BaseAnimation.Spring { profile: "gooey" } 
        }
        Behavior on width { 
            BaseAnimation.Spring { profile: "gooey" } 
        }

        // Gooey "Stretch" effect: scale up during movement
        // We check if the current position is significantly different from the target
        readonly property bool isMoving: Math.abs(x - (layout.x + (activeItem ? activeItem.x : 0))) > 0.5
        scale: isMoving ? 1.04 : 1.0
        transformOrigin: Item.Center
        
        Behavior on scale { BaseAnimation { speed: "fast" } }
    }

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: root.workspaces

            Item {
                id: indicator

                readonly property bool isActive: modelData.id === root.activeWorkspaceId
                readonly property bool hasWindows: modelData.hasWindows

                implicitHeight: Theme.dimensions.barItemHeight
                implicitWidth: isActive ? 55 : 32

                // Update the shared blob's active item reference
                Component.onCompleted: if (isActive) selectionBlob.activeItem = indicator
                onIsActiveChanged: if (isActive) selectionBlob.activeItem = indicator

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        root.localActiveId = modelData.id;
                        syncTimer.restart();
                        Compositor.switchToWorkspace(modelData.idx || modelData.id);
                    }
                }

                BaseText {
                    id: label

                    anchors.fill: parent
                    anchors.verticalCenterOffset: -1 // Adjust for font baseline 
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    
                    text: {
                        if (Preferences.workspaceStyle === 1) return root.toRoman(modelData.idx);
                        if (Preferences.workspaceStyle === 2) return root.toKanji(modelData.idx);
                        return modelData.idx;
                    }
                    pixelSize: Theme.typography.size.medium
                    // Use background for active to contrast with the gradient pill
                    color: indicator.isActive ? Theme.colors.background : (mouseArea.containsMouse ? Theme.colors.primary : Theme.colors.text)
                    weight: (indicator.isActive || indicator.hasWindows) ? Theme.typography.weights.bold : Theme.typography.weights.normal
                    
                    Behavior on color { BaseAnimation { speed: "fast" } }
                }

                // Smooth transitions for the container width - SNAPPY
                Behavior on implicitWidth {
                    BaseAnimation.Spring { profile: "gooey" }
                }
            }
        }
    }

}
