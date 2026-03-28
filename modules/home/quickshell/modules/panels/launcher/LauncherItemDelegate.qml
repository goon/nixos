import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs

Item {
    id: root

    // --- API ---
    property string text: ""
    property string subText: ""
    property string iconSource: "" // Glyph/Icon name
    property string imageSource: "" // Image path/url (takes precedence if valid)
    property bool selected: false
    property color iconColor: Theme.colors.text // Default icon color

    property bool showFallbackIcon: false
    property string fallbackText: ""
    property bool boxedIcon: false

    signal clicked()

    property int itemIndex: -1 // To be set by ListView
    
    width: ListView.view ? ListView.view.width : parent.width
    height: Theme.dimensions.launcherItemHeight
    
    // Entry animation properties
    opacity: 0
    transform: Translate { id: entryTranslate; y: 20 }
    
    Component.onCompleted: {
        entryAnim.start();
    }
    
    ParallelAnimation {
        id: entryAnim
        BaseAnimation { target: root; property: "opacity"; to: 1; speed: "normal"; delay: Math.max(0, Math.min(root.itemIndex * 30, 300)) }
        BaseAnimation { target: entryTranslate; property: "y"; to: 0; speed: "normal"; delay: Math.max(0, Math.min(root.itemIndex * 30, 300)); easing.type: Easing.OutBack }
    }

    Rectangle {
        id: mainBackground
        anchors.fill: parent
        radius: Theme.geometry.radius
        color: Theme.colors.transparent
        
        // Premium Selection Gradient Border
        Item {
            anchors.fill: parent
            opacity: root.selected ? 1.0 : 0
            visible: opacity > 0
            
            Behavior on opacity { BaseAnimation {} }

            // The Gradient "Border"
            Rectangle {
                anchors.fill: parent
                radius: parent.parent.radius
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: Theme.colors.primary }
                    GradientStop { position: 1; color: Theme.colors.secondary }
                }
            }

            // Inner "Cutout" to create the border effect
            Rectangle {
                anchors.fill: parent
                anchors.margins: 1.5 // Slightly thicker for visibility
                radius: parent.parent.radius - 1.5
                color: Theme.colors.surface
                
                // Add the selection tint overlay inside the cutout
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Qt.alpha(Theme.colors.primary, 0.08)
                    visible: root.selected
                }
            }
        }

        // Inner highlight for "glass" look
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.alpha(Theme.colors.text, 0.05) }
                GradientStop { position: 1.0; color: Theme.colors.transparent }
            }
            visible: root.selected
        }

        Behavior on color {
            BaseAnimation {
                duration: Theme.animations.fast
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.geometry.spacing.dynamicPadding
            anchors.rightMargin: Theme.geometry.spacing.dynamicPadding
            spacing: Theme.geometry.spacing.medium
            
            scale: mouseArea.pressed ? 0.98 : 1.0
            Behavior on scale { BaseAnimation { speed: "fast" } }

            // Icon Container
            Item {
                Layout.preferredWidth: Theme.dimensions.iconLarge
                Layout.preferredHeight: Theme.dimensions.iconLarge
                Layout.alignment: Qt.AlignVCenter

                // 1. Icon Glyph
                BaseIcon {
                    anchors.fill: parent
                    icon: root.iconSource
                    text: ""
                    color: root.selected ? Theme.colors.primary : root.iconColor
                    size: root.boxedIcon ? Theme.dimensions.iconLarge : Theme.dimensions.iconMedium
                    boxed: root.boxedIcon
                    visible: !root.imageSource && !root.showFallbackIcon
                }

                // 2. Image (e.g. App Icon)
                Image {
                    anchors.fill: parent
                    source: root.imageSource
                    asynchronous: false // Keeping consistent with previous AppList behavior
                    fillMode: Image.PreserveAspectFit
                    visible: !!root.imageSource && status === Image.Ready
                }

                // 3. Fallback (Text char)
                BaseIcon {
                    anchors.fill: parent
                    icon: ""
                    text: root.fallbackText
                    color: Theme.colors.text
                    size: Theme.dimensions.iconLarge
                    visible: root.showFallbackIcon
                }
            }

            // Text Container
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 0

                BaseText {
                    Layout.fillWidth: true
                    text: root.text
                    color: root.selected ? Theme.colors.text : Theme.colors.muted
                    weight: root.selected ? Theme.typography.weights.bold : Theme.typography.weights.normal
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }

                BaseText {
                    Layout.fillWidth: true
                    text: root.subText
                    visible: !!root.subText
                    font.pixelSize: Theme.typography.size.small
                    color: root.selected ? Theme.alpha(Theme.colors.text, 0.7) : Theme.colors.muted
                    elide: Text.ElideMiddle
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onPositionChanged: (mouse) => {
             // Find the LauncherTab (parent of the ListView)
             var tab = root.ListView.view ? root.ListView.view.parent : null;
             if (tab && tab.isActive && typeof tab.mouseMoveRequested === "function") {
                 tab.mouseMoveRequested(root.itemIndex, mouse);
             }
        }
        
        onClicked: root.clicked()
    }
}

