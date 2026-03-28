import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services

Item {
    id: root

    Layout.alignment: Qt.AlignVCenter
    Layout.fillWidth: false
    implicitWidth: background.implicitWidth
    implicitHeight: Theme.dimensions.barItemHeight

    BaseBlock {
        id: background

        anchors.fill: parent
        paddingHorizontal: Theme.geometry.spacing.dynamicPadding
        paddingVertical: 0
        implicitHeight: Theme.dimensions.barItemHeight
        clickable: true
        hoverEnabled: false
        onClicked: {
            // We'll pass some positioning data to help the popout anchor correctly
            var globalPos = root.mapToItem(null, root.width / 2, 0);
            var topParent = root;
            while (topParent.parent)topParent = topParent.parent
            var barWidth = topParent.width;
            var screen = Quickshell.screens[0];
            var barScreenX = Preferences.barFitToContent ? (screen.width - barWidth) / 2 : Preferences.barMarginSide;
            var screenX = barScreenX + globalPos.x;
            PopoutService.toggleSystemControl(screenX, barScreenX, barScreenX + barWidth, 0);
        }

        BaseIcon {
            Layout.alignment: Qt.AlignCenter
            icon: "tune"
            size: Theme.dimensions.iconBase
            color: background.containsMouse ? Theme.colors.primary : Theme.colors.text
        }

    }

}
