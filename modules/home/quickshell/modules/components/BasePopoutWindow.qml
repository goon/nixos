import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs

/**
 * BasePopoutWindow - a modular panel window. 
 * Inlines logic from BaseFloating and BasePopout for better maintainability.
 */
Item {
    id: root

    // --- State Management ---
    property string panelState: "Closed"
    property bool interactive: panelState === "Open"
    property string panelNamespace: ""
    
    signal opening()
    signal opened()
    signal closing()
    signal closed()

    // --- Positioning & Sizing ---
    property real anchorX: -1
    property real anchorMinX: -1
    property real anchorMaxX: -1
    
    property real fixedWidth: -1
    property real fixedHeight: -1

    property real manualX: -1
    property real manualY: -1
    
    // Internal size trackers
    property real _contentImplicitWidth: 0
    property real _contentImplicitHeight: 0
    Behavior on _contentImplicitHeight {
        BaseAnimation {
            duration: Theme.animations.normal
            easing.type: Theme.animations.easingType
        }
    }
    property alias bodyItem: contentLoader.item

    readonly property real maxContentHeight: {
        var screenH = (popupWindow && popupWindow.screen) ? popupWindow.screen.height : 1080;
        var barSpace = Preferences.barHeight + (Preferences.barMarginTop * 2);
        
        return screenH - barSpace - Preferences.barMarginTop - Theme.geometry.spacing.large;
    }

    // --- Sizing & Margins ---
    readonly property real totalWidthPadding: (root.layoutMargin * 2) + (root.layoutPadding * 2)
    readonly property real totalHeightPadding: (root.layoutMargin * 2) + (root.layoutPadding * 2)

    readonly property real contentWidth: fixedWidth > 0 ? fixedWidth : (_contentImplicitWidth + totalWidthPadding)
    readonly property real contentHeight: {
        var h = fixedHeight > 0 ? fixedHeight : (_contentImplicitHeight + totalHeightPadding);
        return Math.min(h, maxContentHeight);
    }

    readonly property real contentX: {
        if (manualX >= 0) return manualX;
        if (!popupWindow || !popupWindow.screen) return 0;
        var screenW = popupWindow.screen.width;
        if (anchorX < 0) return (screenW - contentWidth) / 2;
        var x = anchorX - (contentWidth / 2);
        var radiusInset = Theme.geometry.radius;
        var minX = (anchorMinX >= 0) ? (anchorMinX + radiusInset) : 0;
        var maxX = (anchorMaxX >= 0) ? (anchorMaxX - contentWidth - radiusInset) : (screenW - contentWidth);
        return Math.max(minX, Math.min(x, maxX));
    }

    readonly property real verticalGap: Preferences.barMarginTop

    readonly property real contentY: {
        if (manualY >= 0) return manualY;
        if (!popupWindow || !popupWindow.screen) return 0;

        var barSpace = Preferences.barHeight + Preferences.barMarginTop;

        if (Preferences.barPosition === "top") {
            return barSpace;
        } else {
            return popupWindow.screen.height - contentHeight - barSpace - verticalGap;
        }
    }

    // --- Styling & Layout ---
    property color color: Theme.alpha(Theme.colors.background, Theme.blur.backgroundOpacity)
    property real layoutMargin: Theme.geometry.spacing.large
    property real layoutPadding: 0
    property real radius: Theme.geometry.radius

    // --- Bar Cutout Geometry ---
    readonly property real barW: {
        if (!popupWindow || !popupWindow.screen) return 0;
        return Preferences.barFitToContent ? PopoutService.barWidth : (popupWindow.screen.width - 2 * Preferences.barMarginSide);
    }
    readonly property real barX: {
        if (!popupWindow || !popupWindow.screen) return 0;
        return (popupWindow.screen.width - barW) / 2;
    }
    readonly property real barY: {
        if (!popupWindow || !popupWindow.screen) return 0;
        return Preferences.barPosition === "top" ? Preferences.barMarginTop : (popupWindow.screen.height - Preferences.barHeight - Preferences.barMarginTop);
    }
    readonly property real barH: Preferences.barHeight

    // Content Slot
    property Component body: null
    default property alias _body: root.body

    // --- Internal Helpers ---
    function open() {
        if (panelState === "Open" || panelState === "Opening") return;
        
        // Stabilize dimensions for animation
        var h = root.contentHeight + root.verticalGap;
        var startOffset = Preferences.barPosition === "top" ? -h : h;
        
        slideInAnimation.from = startOffset;
        slideInAnimation.to = 0;
        
        panelState = "Opening";
        popupWindow.visible = true;
        opening();
        
        // Use a slight delay to ensure window is mapped and properties are settled
        Qt.callLater(() => {
            slideInAnimation.start();
            opacityAnimation.from = 0;
            opacityAnimation.to = 1;
            opacityAnimation.start();
        });
    }

    function close() {
        if (panelState === "Closed" || panelState === "Closing") return;
        
        // Capture current stable height for the exit animation
        var h = root.contentHeight + root.verticalGap;
        var endOffset = Preferences.barPosition === "top" ? -h : h;
        
        slideOutAnimation.from = root.animOffset;
        slideOutAnimation.to = endOffset;
        
        panelState = "Closing";
        closing();
        
        slideOutAnimation.start();
        opacityAnimation.from = 1;
        opacityAnimation.to = 0;
        opacityAnimation.start();
    }

    function toggle() {
        if (panelState === "Open" || panelState === "Opening") close();
        else open();
    }

    // --- Animations ---
    property real animOffset: 0
    property real animOpacity: 0
    
    BaseAnimation {
        id: slideInAnimation
        target: root
        property: "animOffset"
        easing.type: Easing.OutSine
        easing.bezierCurve: []
        onFinished: {
            panelState = "Open";
            opened();
        }
    }

    BaseAnimation {
        id: slideOutAnimation
        target: root
        property: "animOffset"
        onFinished: {
            panelState = "Closed";
            popupWindow.visible = false;
            closed();
        }
    }

    BaseAnimation {
        id: opacityAnimation
        target: root
        property: "animOpacity"
    }

    // --- Window Structure ---
    property alias popupWindow: popup
    
    PanelWindow {
        id: popup
        visible: false
        screen: Quickshell.screens[0]
        color: Theme.colors.transparent
        focusable: true
        WlrLayershell.namespace: root.panelNamespace
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusiveZone: -1

        anchors { top: true; bottom: true; left: true; right: true }

        Item {
            id: emptyBlurArea
            width: 1; height: 1
            opacity: 0
        }

        BackgroundEffect.blurRegion: blurRegionItem

        Region {
            id: blurRegionItem
            item: Preferences.blurEnabled ? visibleBlurArea : emptyBlurArea
            radius: {
                var isTopClipped = contentWrapper.y < 0;
                var isBottomClipped = (contentWrapper.y + contentWrapper.height) > container.height;
                // If the QML is being mathematically sliced by the container bounds, drop the
                // blur radius to 0 to prevent Wayland's rounded blur corners from protruding past
                // the sharp straight QML limits.
                if (isTopClipped || isBottomClipped) return 0;
                return root.radius;
            }
        }

        // Click-outside-to-close
        MouseArea {
            anchors.fill: parent
            enabled: root.interactive
            onClicked: root.close()

            // Desktop Dimming - Dynamically CutOut
            Shape {
                id: dimmingArea
                anchors.fill: parent
                opacity: Preferences.desktopDim * root.animOpacity
                visible: opacity > 0
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    fillColor: "black"
                    strokeColor: "transparent"
                    fillRule: ShapePath.OddEvenFill

                    // Sub-path 1: Entire Screen
                    startX: 0; startY: 0
                    PathLine { x: dimmingArea.width; y: 0 }
                    PathLine { x: dimmingArea.width; y: dimmingArea.height }
                    PathLine { x: 0; y: dimmingArea.height }
                    PathLine { x: 0; y: 0 }

                    // Sub-path 2: The Rounded Cutout
                    PathMove { x: root.barX + Preferences.cornerRadius; y: root.barY }
                    PathLine { x: root.barX + root.barW - Preferences.cornerRadius; y: root.barY }
                    PathArc { 
                        x: root.barX + root.barW; y: root.barY + Preferences.cornerRadius
                        radiusX: Preferences.cornerRadius; radiusY: Preferences.cornerRadius 
                    }
                    PathLine { x: root.barX + root.barW; y: root.barY + root.barH - Preferences.cornerRadius }
                    PathArc { 
                        x: root.barX + root.barW - Preferences.cornerRadius; y: root.barY + root.barH
                        radiusX: Preferences.cornerRadius; radiusY: Preferences.cornerRadius 
                    }
                    PathLine { x: root.barX + Preferences.cornerRadius; y: root.barY + root.barH }
                    PathArc { 
                        x: root.barX; y: root.barY + root.barH - Preferences.cornerRadius
                        radiusX: Preferences.cornerRadius; radiusY: Preferences.cornerRadius 
                    }
                    PathLine { x: root.barX; y: root.barY + Preferences.cornerRadius }
                    PathArc { 
                        x: root.barX + Preferences.cornerRadius; y: root.barY
                        radiusX: Preferences.cornerRadius; radiusY: Preferences.cornerRadius 
                    }
                }
            }
        }

        // Panel Content Area (Static & Clipped)
        Item {
            id: container
            x: root.contentX
            y: root.contentY
            width: root.contentWidth
            height: root.contentHeight + root.verticalGap
            clip: true // Always clip to allow masking from behind the bar

            // Synthetic item tracing the absolute visible bounds for the Wayland Region API which ignores QML clip
            Item {
                id: visibleBlurArea
                x: contentWrapper.x
                y: Math.max(0, contentWrapper.y)
                width: contentWrapper.width
                height: Math.max(0, Math.min(container.height, contentWrapper.y + contentWrapper.height) - y)
            }

            // Moving Content Wrapper
            Item {
                id: contentWrapper
                width: parent.width
                height: root.contentHeight
                y: root.animOffset + root.verticalGap

                // Background Shape
                BaseBackground {
                    id: bgLoader
                    anchors.fill: parent
                    color: root.color
                    radius: root.radius
                }

                // UI Content
                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    sourceComponent: root.body
                    
                    anchors.leftMargin: root.layoutMargin + root.layoutPadding
                    anchors.rightMargin: root.layoutMargin + root.layoutPadding
                    anchors.topMargin: root.layoutMargin + root.layoutPadding
                    anchors.bottomMargin: root.layoutMargin + root.layoutPadding

                    Binding {
                        target: root
                        property: "_contentImplicitHeight"
                        value: contentLoader.item ? contentLoader.item.implicitHeight : 0
                    }
                    Binding {
                        target: root
                        property: "_contentImplicitWidth"
                        value: contentLoader.item ? contentLoader.item.implicitWidth : 0
                    }
                }
            }
            
            focus: true
            Keys.onEscapePressed: root.close()
        }
    }

}
