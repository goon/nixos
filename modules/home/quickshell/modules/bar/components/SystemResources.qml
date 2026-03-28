import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

BaseBlock {
    id: root

    Layout.alignment: Qt.AlignVCenter
    Layout.fillWidth: false
    implicitWidth: layout.implicitWidth + (Theme.geometry.spacing.dynamicPadding * 2)
    implicitHeight: Theme.dimensions.barItemHeight
    paddingVertical: 0
    clickable: true
    hoverEnabled: false
    blockRadius: Theme.geometry.radius

    onClicked: {
        var posInWindow = root.mapToItem(null, root.width / 2, 0);
        var topParent = root;
        while (topParent.parent) topParent = topParent.parent;
        var barWidth = topParent.width;

        var screen = Quickshell.screens[0];
        var barScreenX;
        if (Preferences.barFitToContent) {
            barScreenX = (screen.width - barWidth) / 2;
        } else {
            barScreenX = Preferences.barMarginSide;
        }

        var screenX = barScreenX + posInWindow.x;
        PopoutService.toggleSystemPopout(screenX, barScreenX, barScreenX + barWidth);
    }

    RowLayout {
        id: layout
        Layout.alignment: Qt.AlignCenter
        spacing: Theme.geometry.spacing.medium

        Row {
            spacing: 2
            BaseText {
                text: "CPU"
                pixelSize: Theme.typography.size.medium
                weight: Theme.typography.weights.bold
                color: root.containsMouse ? Theme.colors.primary : Theme.colors.text
            }
            BaseText {
                text: Math.round(Stats.currentCpu * 100) + "%"
                pixelSize: Theme.typography.size.medium
                color: root.containsMouse ? Theme.colors.primary : Theme.colors.text
            }
        }

        BaseSeparator {
            orientation: BaseSeparator.Vertical
            fill: false
            thickness: 1
            Layout.preferredHeight: Theme.dimensions.iconSmall
            Layout.preferredWidth: 1
            opacity: 0.3
            color: Theme.colors.text
        }

        Row {
            spacing: 2
            BaseText {
                text: "RAM"
                pixelSize: Theme.typography.size.medium
                weight: Theme.typography.weights.bold
                color: root.containsMouse ? Theme.colors.primary : Theme.colors.text
            }
            BaseText {
                text: Math.round(Stats.currentRam * 100) + "%"
                pixelSize: Theme.typography.size.medium
                color: root.containsMouse ? Theme.colors.primary : Theme.colors.text
            }
        }
    }
}
