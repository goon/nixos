import QtQuick
import QtQuick.Effects
import qs

PathView {
    id: root

    property int borderRadius: Theme.geometry.radius
    property int centerHeight: 500
    property int sideHeight: 250
    property int gap: Theme.geometry.spacing.large
    readonly property real centerY: root.height / 2
    readonly property real topY: centerY - (centerHeight / 2) - gap - (sideHeight / 2)
    readonly property real bottomY: centerY + (centerHeight / 2) + gap + (sideHeight / 2)
    
    // Far positions can just be off-screen
    readonly property real farTopY: topY - sideHeight - gap
    readonly property real farBottomY: bottomY + sideHeight + gap

    property bool canNavigate: true
    signal closeRequested()

    // --- Logic ---

    function safeDecrement() {
        if (canNavigate) {
            decrementCurrentIndex();
            canNavigate = false;
            navTimer.start();
        }
    }

    function safeIncrement() {
        if (canNavigate) {
            incrementCurrentIndex();
            canNavigate = false;
            navTimer.start();
        }
    }

    function syncToIndex(path) {
        if (model && model.length > 0 && path !== "") {
            for (var i = 0; i < model.length; i++) {
                if (model[i] === path) {
                    currentIndex = i;
                    break;
                }
            }
        }
    }

    function setRandomIndex() {
        if (model && model.length > 0) {
            var newIndex = Math.floor(Math.random() * model.length);
            positionViewAtIndex(newIndex, PathView.Center);
            currentIndex = newIndex;
        }
    }

    function positionViewAtBeginning() {
        currentIndex = 0;
        positionViewAtIndex(0, PathView.Center);
    }

    // --- Configuration ---

    clip: false
    model: Wallpaper.wallpapers
    
    pathItemCount: Math.min(5, model.length)

    preferredHighlightBegin: 0.5
    preferredHighlightEnd: 0.5
    highlightRangeMode: PathView.StrictlyEnforceRange
    snapMode: PathView.SnapToItem
    
    focus: true
    
    // --- Input Handling ---
    
    Keys.onUpPressed: safeDecrement()
    Keys.onDownPressed: safeIncrement()
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_K) {
            safeDecrement();
            event.accepted = true;
        } else if (event.key === Qt.Key_J) {
            safeIncrement();
            event.accepted = true;
        }
    }
    Keys.onEscapePressed: root.closeRequested()
    Keys.onReturnPressed: {
        if (currentIndex >= 0 && model && model.length > currentIndex) {
            Wallpaper.applyWallpaper(model[currentIndex]);
            root.closeRequested();
        }
    }

    Timer {
        id: navTimer
        interval: 150
        repeat: false
        onTriggered: root.canNavigate = true
    }

    // --- Paths ---

    path: standardPath

    Path {
        id: standardPath
        startX: root.width / 2
        startY: -500

        // Start Attributes
        PathAttribute { name: "itemHeight"; value: root.sideHeight }
        PathAttribute { name: "itemZ"; value: 0 }
        PathAttribute { name: "itemOpacity"; value: 0 }
        PathAttribute { name: "dimOpacity"; value: 0.5 }
        PathAttribute { name: "topRadius"; value: root.borderRadius }
        PathAttribute { name: "bottomRadius"; value: 0 }

        // 1. Far Top (Preload)
        PathLine { x: root.width / 2; y: root.farTopY }
        PathAttribute { name: "itemHeight"; value: root.sideHeight }
        PathAttribute { name: "itemZ"; value: 0 }
        PathAttribute { name: "itemOpacity"; value: 0 }
        PathAttribute { name: "dimOpacity"; value: 0.5 }
        PathAttribute { name: "topRadius"; value: root.borderRadius }
        PathAttribute { name: "bottomRadius"; value: 0 }
        PathPercent { value: 0.1 }

        // 2. Top Side (Visible)
        PathLine { x: root.width / 2; y: root.topY }
        PathAttribute { name: "itemHeight"; value: root.sideHeight }
        PathAttribute { name: "itemZ"; value: 1 }
        PathAttribute { name: "itemOpacity"; value: 1 }
        PathAttribute { name: "dimOpacity"; value: 0.4 }
        PathAttribute { name: "topRadius"; value: root.borderRadius }
        PathAttribute { name: "bottomRadius"; value: 0 }
        PathPercent { value: 0.3 }

        // 2b. Pre-Center (Hold Radius)
        PathLine { x: root.width / 2; y: root.topY + (root.centerY - root.topY) * 0.9 }
        PathAttribute { name: "itemHeight"; value: root.sideHeight + (root.centerHeight - root.sideHeight) * 0.9 }
        PathAttribute { name: "itemZ"; value: 99 }
        PathAttribute { name: "itemOpacity"; value: 1 }
        PathAttribute { name: "dimOpacity"; value: 0.1 }
        PathAttribute { name: "topRadius"; value: root.borderRadius } // Hold radius
        PathAttribute { name: "bottomRadius"; value: 0 }
        PathPercent { value: 0.49 }

        // 3. Center (Hero)
        PathLine { x: root.width / 2; y: root.centerY }
        PathAttribute { name: "itemHeight"; value: root.centerHeight }
        PathAttribute { name: "itemZ"; value: 100 }
        PathAttribute { name: "itemOpacity"; value: 1 }
        PathAttribute { name: "dimOpacity"; value: 0 }
        PathAttribute { name: "topRadius"; value: 0 }
        PathAttribute { name: "bottomRadius" ; value: 0 }
        PathPercent { value: 0.5 }

        // 3b. Post-Center (Restore Radius)
        PathLine { x: root.width / 2; y: root.centerY + (root.bottomY - root.centerY) * 0.1 }
        PathAttribute { name: "itemHeight"; value: root.centerHeight - (root.centerHeight - root.sideHeight) * 0.1 }
        PathAttribute { name: "itemZ"; value: 99 }
        PathAttribute { name: "itemOpacity"; value: 1 }
        PathAttribute { name: "dimOpacity"; value: 0.1 }
        PathAttribute { name: "topRadius"; value: 0 }
        PathAttribute { name: "bottomRadius"; value: root.borderRadius } // Restore radius
        PathPercent { value: 0.51 }

        // 4. Bottom Side (Visible)
        PathLine { x: root.width / 2; y: root.bottomY }
        PathAttribute { name: "itemHeight"; value: root.sideHeight }
        PathAttribute { name: "itemZ"; value: 1 }
        PathAttribute { name: "itemOpacity"; value: 1 }
        PathAttribute { name: "dimOpacity"; value: 0.4 }
        PathAttribute { name: "topRadius"; value: 0 }
        PathAttribute { name: "bottomRadius"; value: root.borderRadius }
        PathPercent { value: 0.7 }

        // 5. Far Bottom (Preload)
        PathLine { x: root.width / 2; y: root.farBottomY }
        PathAttribute { name: "itemHeight"; value: root.sideHeight }
        PathAttribute { name: "itemZ"; value: 0 }
        PathAttribute { name: "itemOpacity"; value: 0 }
        PathAttribute { name: "dimOpacity"; value: 0.5 }
        PathAttribute { name: "topRadius"; value: 0 }
        PathAttribute { name: "bottomRadius"; value: root.borderRadius }
        PathPercent { value: 0.9 }

        // End Point
        PathLine { x: root.width / 2; y: root.height + 500 }
        PathAttribute { name: "itemHeight"; value: root.sideHeight }
        PathAttribute { name: "itemZ"; value: 0 }
        PathAttribute { name: "itemOpacity"; value: 0 }
        PathAttribute { name: "dimOpacity"; value: 0.5 }
        PathAttribute { name: "topRadius"; value: 0 }
        PathAttribute { name: "bottomRadius"; value: Theme.geometry.radius * 1.5 }
    }

    delegate: Item {
        id: delegateRoot

        property real dimLevel: (typeof PathView.dimOpacity !== 'undefined') ? PathView.dimOpacity : 0
        property real topRadius: (typeof PathView.topRadius !== 'undefined') ? PathView.topRadius : Theme.geometry.radius
        property real bottomRadius: (typeof PathView.bottomRadius !== 'undefined') ? PathView.bottomRadius : Theme.geometry.radius
        // Model data (file path)
        property string imageSource: modelData || ""

        // PathView injected properties
        height: (typeof PathView.itemHeight !== 'undefined') ? PathView.itemHeight : 150
        width: root.width // Full width in vertical carousel
        
        anchors.horizontalCenter: parent.horizontalCenter
        
        z: (typeof PathView.itemZ !== 'undefined') ? PathView.itemZ : 0
        opacity: (typeof PathView.itemOpacity !== 'undefined') ? PathView.itemOpacity : 0

        // 1. THE STENCIL: Mask Rectangle (Layered)
        Rectangle {
            id: maskRect

            anchors.fill: effectContainer
            visible: false // Hidden, used as texture source
            color: Theme.colors.text // Mask source
            topLeftRadius: delegateRoot.topRadius
            topRightRadius: delegateRoot.topRadius
            bottomLeftRadius: delegateRoot.bottomRadius
            bottomRightRadius: delegateRoot.bottomRadius
            
            // Render to texture for MultiEffect
            layer.enabled: true
            layer.smooth: true
            layer.samples: 8
        }

        // 2. THE CANVAS: Layered Item
        Item {
            id: effectContainer

            anchors.fill: parent
            layer.enabled: true

            // Placeholder / Loading State
            Rectangle {
                anchors.fill: parent
                color: Theme.colors.background
                opacity: 0.1
                visible: imgSource.status !== Image.Ready
            }

            Image {
                id: imgSource

                anchors.fill: parent
                source: "file://" + delegateRoot.imageSource
                fillMode: Image.PreserveAspectCrop
                smooth: true
                cache: true
                asynchronous: true // Prevent blocking
            }

            // Dimming overlay
            Rectangle {
                anchors.fill: parent
                color: Theme.colors.base
                opacity: delegateRoot.dimLevel
            }

            // Highlight border for current item
            Rectangle {
                anchors.fill: parent
                color: Theme.colors.transparent
                border.color: Theme.colors.primary
                border.width: PathView.isCurrentItem ? 2 : 0
                radius: delegateRoot.topRadius 
                visible: PathView.isCurrentItem
                opacity: PathView.isCurrentItem ? 0.3 : 0
            }

            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: maskRect
            }
        }
    }
}
