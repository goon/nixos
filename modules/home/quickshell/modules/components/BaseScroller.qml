import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs

Flickable {
    // No ScrollBars added - cleanest possible implementation

    id: root

    // Emulate ScrollView's availableWidth/availableHeight
    readonly property real availableWidth: width - leftMargin - rightMargin
    readonly property real availableHeight: height - topMargin - bottomMargin

    clip: true
    contentWidth: availableWidth
    contentHeight: contentItem.childrenRect.height // Auto-fit to children
    // Expose implicit height so containers can resize to fit
    implicitHeight: contentHeight
    flickableDirection: Flickable.VerticalFlick
    boundsBehavior: Flickable.StopAtBounds
}
