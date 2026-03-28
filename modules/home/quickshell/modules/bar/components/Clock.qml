import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

BaseBlock {
    id: root
    
    Layout.alignment: Qt.AlignVCenter
    Layout.fillWidth: false
    paddingHorizontal: Theme.geometry.spacing.dynamicPadding
    paddingVertical: 0
    implicitHeight: Theme.dimensions.barItemHeight
    hoverEnabled: false
    clickable: true
    
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
        PopoutService.toggleCalendarPopout(screenX, barScreenX, barScreenX + barWidth);
    }

    // Now supported natively by BaseBlock
    onMiddleClicked: {
        Weather.fetchWeather();
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    // Unified content layout - providing implicit size to BaseBlock correctly
    RowLayout {
        id: layout
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        spacing: Theme.geometry.spacing.medium

        // Time with bold hour
        BaseText {
            text: "<b>" + Qt.formatDateTime(systemClock.date, "hh") + "</b>" + " " + Qt.formatDateTime(systemClock.date, "mm")
            textFormat: Text.RichText
            pixelSize: Theme.typography.size.medium
            weight: Theme.typography.weights.normal
            color: root.containsMouse ? Theme.colors.primary : Theme.colors.text
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

        // Temperature
        BaseText {
            text: Weather.temperature
            pixelSize: Theme.typography.size.medium
            weight: Theme.typography.weights.normal
            color: root.containsMouse ? Theme.colors.primary : Theme.colors.text
        }
    }
}
