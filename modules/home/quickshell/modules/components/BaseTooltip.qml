import QtQuick
import QtQuick.Controls
import qs

/*
 * BaseTooltip - A themed and reusable tooltip component.
 */
ToolTip {
    id: root
    
    // Default delay to prevent flickering
    delay: 500
    
    // Default positioning below the parent
    y: parent.height + Theme.geometry.spacing.small
    
    // Styling the text content
    contentItem: BaseText {
        text: root.text
        color: Theme.colors.text
        pixelSize: Theme.typography.size.base
    }

    // Styling the tooltip background
    background: Rectangle {
        color: Theme.colors.surface
        border.color: Theme.colors.border
        border.width: 1
        radius: Theme.geometry.radius
        
        // Add subtle shadow if needed, but keeping it clean for now
    }
    
    // Ensure padding matches the aesthetic
    padding: Theme.geometry.spacing.small
}
