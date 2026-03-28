import qs
import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root
    
    enum Orientation {
        Horizontal,
        Vertical
    }
    
    property int orientation: BaseSeparator.Horizontal
    property int thickness: 1
    property int length: 20 // Only used if not filling width/height in layout
    
    implicitWidth: orientation === BaseSeparator.Vertical ? thickness : length
    implicitHeight: orientation === BaseSeparator.Horizontal ? thickness : length
    
    property bool fill: true
    
    // Support for Layout.fillWidth/fillHeight
    Layout.fillWidth: fill && orientation === BaseSeparator.Horizontal
    Layout.fillHeight: fill && orientation === BaseSeparator.Vertical
    
    color: Theme.colors.border
    radius: thickness > 1 ? thickness / 2 : 0
}
