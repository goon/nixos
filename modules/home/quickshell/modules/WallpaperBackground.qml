import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

/**
 * Wallpaper Background Window
 * 
 * Manages the background layer across all screens.
 * Uses a double-buffering approach with crossfade transitions.
 * Implements "Load-Gated Transitions" to ensure animations only start when textures are ready.
 */
PanelWindow {
    id: root

    // --- State ---
    property string activePath: ""
    property bool bufferToggle: false // false: A is active, true: B is active
    property bool transitionPending: false

    property real mouseX: 0.5
    property real mouseY: 0.5

    // --- Logic ---

    function updateWallpaper(newPath) {
        if (!newPath || newPath === "" || newPath === activePath) return;
        

        
        // 1. Determine target buffer (The one NOT currently visible)
        var targetLoader = !bufferToggle ? loaderB : loaderA;
        
        // 2. Set source - this will trigger the image load
        transitionPending = true;
        targetLoader.source = "file://" + newPath;
        
        // Handle case where source didn't change or loaded instantly
        if (targetLoader.status === Image.Ready) {
            checkAndTransition();
        }
        
        // 3. Update state tracking (we commit the path now so we don't queue duplicates)
        activePath = newPath;
    }

    function checkAndTransition() {
        if (!transitionPending) return;

        var targetLoader = !bufferToggle ? loaderB : loaderA;
        
        // Only start transition if the image is actually loaded and ready to render
        if (targetLoader.status === Image.Ready) {
            
            // Set up transition
            transition.sourceOld = bufferToggle ? loaderB : loaderA;
            transition.sourceNew = targetLoader;
            
            // Start Animation
            transition.startTransition(0); // 0 = Crossfade
            
            // Commit Buffer Flip
            bufferToggle = !bufferToggle;
            transitionPending = false;
        }
    }

    // --- Connections ---

    Connections {
        target: Wallpaper
        function onDisplayWallpaperChanged() {
            root.updateWallpaper(Wallpaper.displayWallpaper);
        }
    }

    Component.onCompleted: {
        if (Wallpaper.displayWallpaper !== "") {
            loaderA.source = "file://" + Wallpaper.displayWallpaper;
            // For initial load, we don't animate, we just show it if ready
            if (loaderA.status === Image.Ready) {
                loaderA.opacity = 1;
                loaderA.visible = true;
            }
            activePath = Wallpaper.displayWallpaper;
        }
    }

    // --- Layout Shell Config ---
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "wallpaper"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: 0
    visible: true
    color: Theme.colors.background

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    margins {
        top: (Preferences.barPosition === "top") ? -(Preferences.barHeight + Preferences.barMarginTop) : 0
        bottom: (Preferences.barPosition === "bottom") ? -(Preferences.barHeight + Preferences.barMarginTop) : 0
    }

    // --- Buffers ---

    Image {
        id: loaderA
        anchors.centerIn: parent
        width: parent.width + (Preferences.wallpaperParallaxEnabled ? Preferences.wallpaperParallaxStrength * 2 : 0)
        height: parent.height + (Preferences.wallpaperParallaxEnabled ? Preferences.wallpaperParallaxStrength * 2 : 0)
        visible: false
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        
        // Trigger transition when load completes
        onStatusChanged: if (status === Image.Ready) root.checkAndTransition()

        transform: Translate {
            x: Preferences.wallpaperParallaxEnabled ? (root.mouseX - 0.5) * -Preferences.wallpaperParallaxStrength : 0
            y: Preferences.wallpaperParallaxEnabled ? (root.mouseY - 0.5) * -Preferences.wallpaperParallaxStrength : 0

            Behavior on x { BaseAnimation { duration: Theme.animations.slow } }
            Behavior on y { BaseAnimation { duration: Theme.animations.slow } }
        }

        Behavior on width { BaseAnimation { duration: Theme.animations.slow } }
        Behavior on height { BaseAnimation { duration: Theme.animations.slow } }
    }

    Image {
        id: loaderB
        anchors.centerIn: parent
        width: parent.width + (Preferences.wallpaperParallaxEnabled ? Preferences.wallpaperParallaxStrength * 2 : 0)
        height: parent.height + (Preferences.wallpaperParallaxEnabled ? Preferences.wallpaperParallaxStrength * 2 : 0)
        visible: false
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        
        // Trigger transition when load completes
        onStatusChanged: if (status === Image.Ready) root.checkAndTransition()

        transform: Translate {
            x: Preferences.wallpaperParallaxEnabled ? (root.mouseX - 0.5) * -Preferences.wallpaperParallaxStrength : 0
            y: Preferences.wallpaperParallaxEnabled ? (root.mouseY - 0.5) * -Preferences.wallpaperParallaxStrength : 0

            Behavior on x { BaseAnimation { duration: Theme.animations.slow } }
            Behavior on y { BaseAnimation { duration: Theme.animations.slow } }
        }

        Behavior on width { BaseAnimation { duration: Theme.animations.slow } }
        Behavior on height { BaseAnimation { duration: Theme.animations.slow } }
    }

    // --- Internal Transition Logic ---
    Item {
        id: transition
        anchors.fill: parent
        
        property Item sourceOld
        property Item sourceNew
        property int type: 0
        property bool running: false
        property int duration: Theme.animations.slow * 2 // Long crossfade

        signal finished()

        function prepare() {
            if (sourceOld) {
                sourceOld.opacity = 1;
                sourceOld.x = 0;
                sourceOld.y = 0;
                sourceOld.visible = true;
                sourceOld.scale = 1;
                sourceOld.z = 1;
                sourceNew.z = 2;
                sourceOld.z = 1;
            }
            if (sourceNew) {
                sourceNew.opacity = 1;
                sourceNew.x = 0;
                sourceNew.y = 0;
                sourceNew.scale = 1;
                sourceNew.visible = false;
            }
        }

        function startTransition(newType) {
            transition.type = newType;
            prepare();
            if (type === 1) { // Zoom
                sourceNew.scale = 0.5;
                sourceNew.opacity = 0;
                sourceNew.visible = true;
                animZoom.restart();
            } else { // Crossfade
                sourceNew.opacity = 0;
                sourceNew.visible = true;
                animFade.restart();
            }
            transition.running = true;
        }

        BaseAnimation {
            id: animFade
            target: transition.sourceNew
            property: "opacity"
            from: 0
            to: 1
            duration: transition.duration
            easing.type: Easing.InOutQuad
            onFinished: transition.finished()
        }

        ParallelAnimation {
            id: animZoom
            onFinished: transition.finished()

            BaseAnimation {
                target: transition.sourceNew
                property: "scale"
                from: 1.2
                to: 1
                duration: transition.duration
                easing.type: Easing.OutCubic
            }

            BaseAnimation {
                target: transition.sourceNew
                property: "opacity"
                from: 0
                to: 1
                duration: transition.duration
            }
        }
    }

    MouseArea {
        id: mouseTracker
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.LeftButton
        enabled: Preferences.wallpaperParallaxEnabled
        z: 999
        onPositionChanged: (mouse) => {
            root.mouseX = mouse.x / width;
            root.mouseY = mouse.y / height;
        }
        onExited: {
            root.mouseX = 0.5;
            root.mouseY = 0.5;
        }
    }
}
