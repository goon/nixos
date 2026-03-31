import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

BaseBlock {
    id: root

    Layout.alignment: Qt.AlignVCenter
    Layout.fillWidth: false
    implicitWidth: layout.implicitWidth + (paddingHorizontal * 2)
    implicitHeight: Theme.dimensions.barItemHeight
    paddingHorizontal: Theme.geometry.spacing.dynamicPadding
    paddingVertical: 0
    blockRadius: Theme.geometry.radius
    clickable: true
    hoverEnabled: false

    Component.onCompleted: PopoutService.volumeItem = root
    Component.onDestruction: PopoutService.volumeItem = null

    onClicked: {
        PopoutService.toggleAudioPopout();
    }
    onRightClicked: Volume.toggleMute()

    // Wrap content to avoid ColumnLayout vs Anchors conflict in BaseBlock
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight

        // Internal MouseArea for Wheel and Middle Click (BaseBlock only handles Left/Right)
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.MiddleButton
            onClicked: (mouse) => {
                if (mouse.button === Qt.MiddleButton)
                    Volume.toggleMute();

            }
            onWheel: (wheel) => {
                let delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                Volume.setVolume(Math.max(0, Math.min(1, Volume.volume + delta)));
            }
        }

        RowLayout {
            id: layout

            anchors.centerIn: parent
            spacing: 2

            BaseText {
                text: "VOL"
                pixelSize: Theme.typography.size.medium
                weight: Theme.typography.weights.bold
                color: root.containsMouse ? Theme.colors.primary : Theme.colors.text
            }

            BaseText {
                text: Volume.muted ? "MUTED" : Volume.volumePercent + "%"
                pixelSize: Theme.typography.size.medium
                color: root.containsMouse ? Theme.colors.primary : Theme.colors.text
            }

        }

    }

}
